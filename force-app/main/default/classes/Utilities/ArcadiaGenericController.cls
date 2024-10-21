public virtual inherited sharing class ArcadiaGenericController {
    public static Exception handleException(String className, Exception e) {
        String inJSON = null;
        return handleException(className, e, inJSON);
    }

    public static Exception handleException(String className, Exception e, Map<String, Object> parameters) {
        String inJSON = (parameters != null) ? JSON.serialize(parameters) : null;
        return handleException(className, e, inJSON);
    }

    public static Exception handleException(String className, Exception e, String inJSON) {
        String errorCode;
        String errorMessage;

        if (e instanceof GenericControllerException) {
            errorMessage = e.getMessage();
            //Do not Log CalloutServiceExceptions, already been logged
        } else if (e instanceof ArcadiaCalloutServiceException) {
            errorMessage = String.format(
                System.Label.Arcadia_Generic_ErrorText,
                new List<String>{ ((ArcadiaCalloutServiceException) e).errorCode }
            );
        } else {
            errorCode = generateErrorCode();
            Logger logInstance = Logger.getPlatformLogger();
            logInstance.log(className, e, inJSON, errorCode);
            errorMessage = String.format(System.Label.Arcadia_Generic_ErrorText, new List<String>{ errorCode });
        }

        return new GenericControllerException(errorMessage, e);
    }

    public static String generateErrorCode() {
        Blob b = Crypto.GenerateAESKey(128);
        return EncodingUtil.ConvertTohex(b).substring(0, 8);
    }

    //Function called to check wether or not the SaveResult is success or failed
    //If the SaveResult indicates that there is an error, throw an exception
    public static void handleDMLErrors(Database.SaveResult saveResultObj) {
        List<String> lstErrorMessages = new List<String>();
        if (!saveResultObj.isSuccess()) {
            for (Database.Error err : saveResultObj.getErrors()) {
                String ErrorMessage = err.getStatusCode() + ' : ' + err.getMessage();
                lstErrorMessages.add(ErrorMessage);
            }
        }
        if (!lstErrorMessages.isEmpty()) {
            throw new GenericDMLException(JSON.serialize(lstErrorMessages));
        }
    }

    //Function called to check wether or not the SaveResult is success or failed
    //If the SaveResult indicates that there is an error, throw an exception
    public static void handleDMLErrors(Database.UpsertResult upsertResultObj) {
        List<String> lstErrorMessages = new List<String>();
        if (!upsertResultObj.isSuccess()) {
            for (Database.Error err : upsertResultObj.getErrors()) {
                String ErrorMessage = err.getStatusCode() + ' : ' + err.getMessage();
                lstErrorMessages.add(ErrorMessage);
            }
        }
        if (!lstErrorMessages.isEmpty()) {
            throw new GenericDMLException(JSON.serialize(lstErrorMessages));
        }
    }

    public virtual class GenericControllerException extends Exception {
    }

    public virtual class GenericDMLException extends Exception {
    }
}