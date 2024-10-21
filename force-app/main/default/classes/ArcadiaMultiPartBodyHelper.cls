public with sharing class ArcadiaMultiPartBodyHelper {
    ///////////////Start private Variables////////////////
    @testVisible
    private final static String strBoundary = '1ff13444ed8140c7a32fc4e6451aa76d';
    ///////////////End private Variables////////////////

    ///////////////Start public Methods////////////////
    //returns the contenty type value for multipart using the constant boundary value
    public String GetContentType() {
        return 'multipart/form-data; charset="UTF-8"; boundary="' + strBoundary + '"';
    }

    //function used to write boundary between the different parameters of the multi part form body
    public String WriteBoundary() {
        String value = '--' + strBoundary + '\r\n';
        blob valueBlob = blob.valueOf(value);

        return EncodingUtil.base64Encode(valueBlob);
    }

    //function called to write the proper boundary ending to the multi part form body
    public String WriteEndingBoundary(EndingType strEnding) {
        String value = '';

        //the file needs to be ended with a proper '\r\n' before the boundary... so based on the current ending we append value to
        //make sure it is proper ended , if file is ending by double '=' then it is already replaced by line break and no need to append anything
        if (strEnding == EndingType.Cr) {
            // if the file's base64 was padded with a single =, it was replaced with '\r' so we have to append '\n' to have a valid line break
            value += '\n';
        } else if (strEnding == EndingType.None) {
            //if file was not padded then we need to append a line break
            value += '\r\n';
        }

        value += '--' + strBoundary + '--';

        blob valueBlob = blob.valueOf(value);

        return EncodingUtil.base64Encode(valueBlob);
    }

    //function called to write a key value pair in the multi part form body
    public String WriteBodyParameter(String key, String value) {
        String contentDisposition = 'Content-Disposition: form-data; name="' + key + '"';
        String contentDispositionCrLf = contentDisposition + '\r\n\r\n';
        blob contentDispositionCrLfBlob = blob.valueOf(contentDispositionCrLf);
        String contentDispositionCrLf64 = EncodingUtil.base64Encode(contentDispositionCrLfBlob);
        String parameterContent = PadValueSafely(contentDisposition, contentDispositionCrLf64, '\r\n\r\n');
        String valueCrLf = value + '\r\n';
        blob valueCrLfBlob = blob.valueOf(valueCrLf);
        String valueCrLf64 = EncodingUtil.base64Encode(valueCrLfBlob);
        parameterContent += PadValueSafely(value, valueCrLf64, '\r\n');
        return parameterContent;
    }

    //function called to write a key value pair in the multi part form body for a blob (file content)
    public String WriteBlobBodyParameter(String key, String jsonFileDetails) {
        FileRequestDetails fileDetailsObj = (FileRequestDetails) JSON.deserialize(
            jsonFileDetails,
            FileRequestDetails.class
        );
        String contentDisposition =
            'Content-Disposition: form-data; name="' +
            key +
            '"; filename="' +
            fileDetailsObj.fileName +
            '"';
        String contentDispositionCrLf = contentDisposition + '\r\n';
        blob contentDispositionCrLfBlob = blob.valueOf(contentDispositionCrLf);
        String contentDispositionCrLf64 = EncodingUtil.base64Encode(contentDispositionCrLfBlob);
        List<String> lstContent = new List<String>{
            PadValueSafely(contentDisposition, contentDispositionCrLf64, '\r\n')
        };
        String contentTypeHeader = 'Content-Type: ' + getFileMimeType(fileDetailsObj.fileName);
        String contentTypeCrLf = contentTypeHeader + '\r\n\r\n';
        blob contentTypeCrLfBlob = blob.valueOf(contentTypeCrLf);
        String contentTypeCrLf64 = EncodingUtil.base64Encode(contentTypeCrLfBlob);
        lstContent.add(PadValueSafely(contentTypeHeader, contentTypeCrLf64, '\r\n\r\n'));

        integer file64Length = EncodingUtil.base64Encode(fileDetailsObj.fileContent).length();
        String last4Bytes = EncodingUtil.base64Encode(fileDetailsObj.fileContent)
            .substring(file64Length - 4, file64Length);

        EndingType ending = EndingType.None;
        if (last4Bytes.endsWith('==')) {
            // The '==' sequence indicates that the last group contained only one 8 bit byte
            // 8 digit binary representation of CR is 00001101
            // 8 digit binary representation of LF is 00001010
            // append them together to have 0000110100001010
            // then split them into 6 bit chunks starting from the right 0000 110100 001010
            // Note the first 4 bits 0000 are identical to the padding used to encode the
            // second original 6 bit chunk, this is handy it means we can hard code the response in
            // The decimal values of 110100 --> is 52 AND  001010 is -->  10
            // The base64 mapping values of 52 -->'0' AND 10 base64 mapping --> is 'K'
            // Check http://en.wikipedia.org/wiki/Base64 for base64 mapping table
            // so we will replace '==' with '0K'
            last4Bytes = last4Bytes.substring(0, 2) + '0K';
            // We have appended the \r\n to the Blob, so leave footer as it is.
            ending = EndingType.CrLf;
        } else if (last4Bytes.endsWith('=')) {
            // '=' indicates that encoded data already contained two out of 3x 8 bit bytes
            // We replace final 8 bit byte with a CR e.g. \r
            // 8 digit binary representation of CR is 00001101
            // Ignore the first 2 bits of 00 001101 they have already been used up as padding
            // for the existing data.
            // The Decimal value of 001101 is 13 and its base64 mapping based on the wikipedia table is 'N'
            // so we will replace '=' with 'N'
            last4Bytes = last4Bytes.substring(0, 3) + 'N';
            // We have appended the CR e.g. \r, still need to prepend the line feed to the footer
            ending = EndingType.Cr;
        }

        lstContent.add(
            EncodingUtil.base64Encode(fileDetailsObj.fileContent).substring(0, file64Length - 4) + last4Bytes
        );
        lstContent.add(WriteEndingBoundary(ending));
        return String.join(lstContent, '');
    }
    ///////////////End public Methods////////////////

    ///////////////Start private Methods////////////////
    //this method id called to Pad the String value passed with spaces until the base64 encoding is no longer padded.
    private String PadValueSafely(String value, String valueCrLf64, String lineBreaks) {
        String valueCrLf = '';
        blob valueCrLfBlob = null;
        while (valueCrLf64.endsWith('=')) {
            value += ' ';
            valueCrLf = value + lineBreaks;
            valueCrLfBlob = blob.valueOf(valueCrLf);
            valueCrLf64 = EncodingUtil.base64Encode(valueCrLfBlob);
        }
        return valueCrLf64;
    }

    //function used to get the file mime type from the file name based on the extension
    private String getFileMimeType(String fileName) {
        String fileType = fileName.substringAfterLast('.');
        String mimeType = 'application/pdf'; // default mime type if the file type is not matching
        if (!fileType.equalsIgnoreCase('pdf')) {
            throw new InvalidMimeTypeException('File must be a PDF.');
        }
        return mimeType;
    }
    ///////////////End private Methods////////////////

    //enum indicating how a file's base64 padding was replaced.
    public enum EndingType {
        Cr,
        CrLf,
        None
    }

    public class InvalidMimeTypeException extends Exception {
    }

    public class FileRequestDetails {
        public String fileName;
        public Blob fileContent;
    }
}