public class ArcadiaCalloutServiceException extends Exception {
    public String errorCode { get; set; }
    public Integer status { get; set; }

    public ArcadiaCalloutServiceException(String message, Exception e, String errorCode) {
        this(message, e);
        this.errorCode = errorCode;
    }

    public ArcadiaCalloutServiceException(String message, String errorCode) {
        this(message);
        this.errorCode = errorCode;
    }

    public ArcadiaCalloutServiceException(String message, Integer status) {
        this(message);
        this.status = status;
    }
}