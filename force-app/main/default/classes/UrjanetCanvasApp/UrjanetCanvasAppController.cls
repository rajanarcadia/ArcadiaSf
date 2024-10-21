public with sharing class UrjanetCanvasAppController {
    public String pathString { get; set; }
    public String credentialId { get; set; }
    public String thisNamespace { get; set; }
    public String successMessage { get; set; }
    public String failureMessage { get; set; }
    public UrjanetCanvasAppController() {
        this.credentialId = String.escapeSingleQuotes(apexpages.currentPage().getparameters().get('id'));
        this.pathString = getPathString();
        this.thisNamespace = UrjanetUtils.getThisNameSpace();
        this.successMessage = UrjanetConstants.SUCCESS_MESSAGE;
        this.failureMessage = UrjanetConstants.FAILURE_MESSAGE;
    }

    public String getPathString() {
        Map<String, String> pathMap = new Map<String, String>();
        Exception ex = null;
        try {
            pathMap = UrjanetCanvasAppService.getAlternatePath(this.credentialId);
        } catch (Exception e) {
            ex = e;
            throw new VisualforceException();
        } finally {
            if (ex != null) {
                Logger.getInstance().log(UrjanetCanvasAppController.class.getName(), ex);
            }
        }
        return JSON.serialize(pathMap);
    }

    public void updateCredentialStatus() {
        Exception ex = null;
        try {
            UrjanetCanvasAppService.updateCredentialStatus(this.credentialId);
        } catch (Exception e) {
            ex = e;
            throw new VisualforceException();
        } finally {
            if (ex != null) {
                Logger.getInstance().log(UrjanetCanvasAppController.class.getName(), ex);
            }
        }
    }
}