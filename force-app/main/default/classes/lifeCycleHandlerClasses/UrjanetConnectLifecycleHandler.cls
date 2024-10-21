public with sharing class UrjanetConnectLifecycleHandler implements Canvas.CanvasLifecycleHandler {
    public Canvas.ApplicationContext app;
    public Canvas.EnvironmentContext env;
    public Set<Canvas.ContextTypeEnum> excludeContextTypes() {
        Set<Canvas.ContextTypeEnum> excluded = new Set<Canvas.ContextTypeEnum>();

        return excluded;
    }

    public void onRender(Canvas.RenderContext renderContext) {
        String path = getCustomPath(renderContext);
        app = renderContext.getApplicationContext();
        app.setCanvasUrlPath(path);
    }

    private String getCustomPath(Canvas.RenderContext renderContext) {
        String path;
        env = renderContext.getEnvironmentContext();
        Map<String, Object> parameters = (Map<String, Object>) JSON.deserializeUntyped(env.getParametersAsJSON());
        Object pathValue = parameters.get('path');
        if (pathValue != null) {
            path = pathValue.ToString();
        }
        return path;
    }
}