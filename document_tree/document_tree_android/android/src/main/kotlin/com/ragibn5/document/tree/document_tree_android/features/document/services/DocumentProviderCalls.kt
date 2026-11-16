package com.ragibn5.document.tree.document_tree_android.features.document.services

import com.ragibn5.document.tree.document_tree_android.exceptions.DocumentTreeException
import com.ragibn5.document.tree.document_tree_android.features.document.constants.DocumentWriteExceptionCodes
import java.io.FileNotFoundException

/**
 * Calls that change a document through its provider, such as renaming it.
 */
internal object DocumentProviderCalls {
    /**
     * Runs [call], which does [action] to the document at [path], such as `rename`.
     *
     * @return what [call] returned.
     * @throws DocumentTreeException with a [DocumentWriteExceptionCodes] code if [call] fails or
     * returns `null` or `false`, as providers do on older Android versions.
     */
    fun <T : Any> run(action: String, path: String, call: () -> T?): T {
        val result = try {
            call()
        } catch (e: SecurityException) {
            throw DocumentTreeException(
                DocumentWriteExceptionCodes.ACCESS_LOST,
                e.message ?: "The grant no longer covers the tree",
                cause = e
            )
        } catch (e: UnsupportedOperationException) {
            throw unsupported(action, path, e)
        } catch (e: FileNotFoundException) {
            throw failed(action, path, e)
        } catch (e: IllegalArgumentException) {
            throw failed(action, path, e)
        } catch (e: IllegalStateException) {
            throw failed(action, path, e)
        }

        if (result == null || result == false) {
            throw failed(action, path)
        }
        return result
    }

    /**
     * The failure to throw when the provider of the document at [path] doesn't support [action].
     */
    fun unsupported(action: String, path: String, cause: Throwable? = null) = DocumentTreeException(
        DocumentWriteExceptionCodes.UNSUPPORTED_OPERATION,
        "The provider doesn't support the $action of: $path",
        cause = cause
    )

    private fun failed(action: String, path: String, cause: Throwable? = null) = DocumentTreeException(
        DocumentWriteExceptionCodes.WRITE_ERROR,
        cause?.message ?: "The provider failed the $action of: $path",
        cause = cause
    )
}
