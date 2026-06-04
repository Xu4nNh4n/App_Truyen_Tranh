const functions = require("firebase-functions");
const admin = require("firebase-admin");
const crypto = require("crypto");
const qs = require("qs");

admin.initializeApp();

const db = admin.firestore();


const PACKAGES = {
  coins_50: {
    xu: 50,
    amount: 1,
    name: "Goi 50 xu",
  },
  coins_100: {
    xu: 100,
    amount: 2,
    name: "Goi 100 xu",
  },
  coins_200: {
    xu: 200,
    amount: 3,
    name: "Goi 200 xu",
  },
};

/**
 * Sorts an object by key for VNPAY signature generation.
 * @param {Object} obj Raw parameter object.
 * @return {Object} Sorted parameter object.
 */
function sortObject(obj) {
  const sorted = {};
  const keys = Object.keys(obj).sort();

  for (const key of keys) {
    sorted[key] = obj[key];
  }

  return sorted;
}

/**
 * Creates the VNPAY HMAC SHA512 secure hash.
 * @param {Object} params VNPAY parameters without vnp_SecureHash.
 * @return {string} Hex encoded signature.
 */
function createSecureHash(params) {
  const sortedParams = sortObject(params);
  const signData = qs.stringify(sortedParams, {encode: false});

  return crypto
      .createHmac("sha512", VNPAY_CONFIG.hashSecret)
      .update(Buffer.from(signData, "utf-8"))
      .digest("hex");
}

/**
 * Formats date as yyyyMMddHHmmss for VNPAY.
 * @param {Date} date Date object.
 * @return {string} VNPAY formatted date.
 */
function formatDate(date) {
  const pad = (n) => n.toString().padStart(2, "0");

  return (
    date.getFullYear().toString() +
      pad(date.getMonth() + 1) +
      pad(date.getDate()) +
      pad(date.getHours()) +
      pad(date.getMinutes()) +
      pad(date.getSeconds())
  );
}

exports.createVnpayPayment = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
        "unauthenticated",
        "Ban can dang nhap de nap xu.",
    );
  }

  const uid = context.auth.uid;
  const packageId = data.packageId;
  const selectedPackage = PACKAGES[packageId];

  if (!selectedPackage) {
    throw new functions.https.HttpsError(
        "invalid-argument",
        "Goi xu khong hop le.",
    );
  }

  const txnRef = `${Date.now()}_${uid.slice(0, 8)}`;
  const now = new Date();

  await db.collection("payments").doc(txnRef).set({
    uid,
    packageId,
    xu: selectedPackage.xu,
    amount: selectedPackage.amount,
    status: "pending",
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    credited: false,
  });

  const vnpParams = {
    vnp_Version: "2.1.0",
    vnp_Command: "pay",
    vnp_TmnCode: VNPAY_CONFIG.tmnCode,
    vnp_Amount: selectedPackage.amount * 100,
    vnp_CurrCode: "VND",
    vnp_TxnRef: txnRef,
    vnp_OrderInfo: `Nap ${selectedPackage.xu} xu`,
    vnp_OrderType: "other",
    vnp_Locale: "vn",
    vnp_ReturnUrl: VNPAY_CONFIG.returnUrl,
    vnp_IpAddr: "127.0.0.1",
    vnp_CreateDate: formatDate(now),
    vnp_IpnUrl: VNPAY_CONFIG.ipnUrl,
  };

  const secureHash = createSecureHash(vnpParams);
  const paymentUrl =
    VNPAY_CONFIG.payUrl +
    "?" +
    qs.stringify(sortObject(vnpParams), {encode: true}) +
    "&vnp_SecureHash=" +
    secureHash;

  return {
    txnRef,
    paymentUrl,
  };
});

exports.vnpayReturn = functions.https.onRequest((req, res) => {
  res.send(`
    <html>
      <head>
        <meta charset="utf-8" />
        <title>Ket qua thanh toan</title>
      </head>
      <body>
        <h2>Thanh toan da duoc xu ly</h2>
        <p>
          Ban co the quay lai app. Neu giao dich thanh cong,
          xu se duoc cong sau vai giay.
        </p>
      </body>
    </html>
  `);
});

exports.vnpayIpn = functions.https.onRequest(async (req, res) => {
  try {
    const vnpParams = {...req.query, ...req.body};

    const secureHash = vnpParams.vnp_SecureHash;
    delete vnpParams.vnp_SecureHash;
    delete vnpParams.vnp_SecureHashType;

    const signed = createSecureHash(vnpParams);

    if (secureHash !== signed) {
      return res.status(200).json({
        RspCode: "97",
        Message: "Invalid checksum",
      });
    }

    const txnRef = vnpParams.vnp_TxnRef;
    const responseCode = vnpParams.vnp_ResponseCode;
    const transactionStatus = vnpParams.vnp_TransactionStatus;
    const paidAmount = Number(vnpParams.vnp_Amount) / 100;

    const paymentRef = db.collection("payments").doc(txnRef);

    await db.runTransaction(async (transaction) => {
      const paymentSnap = await transaction.get(paymentRef);

      if (!paymentSnap.exists) {
        throw new Error("ORDER_NOT_FOUND");
      }

      const payment = paymentSnap.data();

      if (Math.round(payment.amount * 100) !== Math.round(paidAmount * 100)) {
        throw new Error("INVALID_AMOUNT");
      }

      if (payment.credited === true) {
        return;
      }

      if (responseCode !== "00" || transactionStatus !== "00") {
        transaction.update(paymentRef, {
          status: "failed",
          vnpResponse: vnpParams,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        return;
      }

      const userRef = db.collection("nguoiDung").doc(payment.uid);

      transaction.update(userRef, {
        xu: admin.firestore.FieldValue.increment(payment.xu),
      });

      transaction.update(paymentRef, {
        status: "paid",
        credited: true,
        paidAt: admin.firestore.FieldValue.serverTimestamp(),
        vnpResponse: vnpParams,
      });
    });

    return res.status(200).json({
      RspCode: "00",
      Message: "Confirm Success",
    });
  } catch (e) {
    if (e.message === "ORDER_NOT_FOUND") {
      return res.status(200).json({
        RspCode: "01",
        Message: "Order not found",
      });
    }

    if (e.message === "INVALID_AMOUNT") {
      return res.status(200).json({
        RspCode: "04",
        Message: "Invalid amount",
      });
    }

    return res.status(200).json({
      RspCode: "99",
      Message: "Unknown error",
    });
  }
});
