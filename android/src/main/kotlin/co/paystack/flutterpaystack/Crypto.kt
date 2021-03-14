package co.paystack.flutterpaystack

import android.util.Base64

import java.security.KeyFactory
import java.security.NoSuchAlgorithmException
import java.security.PublicKey
import java.security.spec.InvalidKeySpecException
import java.security.spec.X509EncodedKeySpec

import javax.crypto.Cipher


/**
 * Class for encrypting the card details, for token creation.
 *
 * @author {androidsupport@paystack.co} on 8/10/15.
 */
object Crypto {

    private const val PAYSTACK_RSA_PUBLIC_KEY = "MFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBANIsL+RHqfkBiKGn/D1y1QnNrMkKzxWP" +
            "2wkeSokw2OJrCI+d6YGJPrHHx+nmb/Qn885/R01Gw6d7M824qofmCvkCAwEAAQ=="
    private const val ALGORITHM = "RSA"
    private const val CIPHER = "RSA/ECB/PKCS1Padding"

    private fun encrypt(text: String, key: PublicKey): ByteArray? {
        var cipherText: ByteArray? = null

        try {

            // get an RSA cipher object
            val cipher = Cipher.getInstance(CIPHER)

            //init cipher and encrypt the plain text using the public key
            cipher.init(Cipher.ENCRYPT_MODE, key)
            cipherText = cipher.doFinal(text.toByteArray())

        } catch (e: Exception) {

            e.printStackTrace()
        }

        return cipherText
    }
    

    @Throws(SecurityException::class)
    fun encrypt(text: String): String {
        return String(Base64.encode(encrypt(text, getPublicKeyFromString(PAYSTACK_RSA_PUBLIC_KEY)), Base64.NO_WRAP))
    }
    

    @Throws(SecurityException::class)
    private fun getPublicKeyFromString(pubKey: String): PublicKey {

        val key: PublicKey

        try {
            //init keyFactory
            val kf = KeyFactory.getInstance(ALGORITHM)

            //decode the key into a byte array
            val keyBytes = Base64.decode(pubKey, Base64.NO_WRAP)

            //create spec
            val spec = X509EncodedKeySpec(keyBytes)

            //generate public key
            key = kf.generatePublic(spec)
        } catch (e: InvalidKeySpecException) {
            throw SecurityException("Invalid public key: " + e.message)
        } catch (e: NoSuchAlgorithmException) {
            throw SecurityException("Invalid public key: " + e.message)
        }

        return key

    }
}
