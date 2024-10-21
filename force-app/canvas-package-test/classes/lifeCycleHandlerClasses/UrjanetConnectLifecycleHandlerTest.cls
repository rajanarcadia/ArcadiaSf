@isTest
public class UrjanetConnectLifecycleHandlerTest {
    @isTest
    static void testDefaultMockValues() {
        // Test handler using the default mock RenderContext Canvas.Test creates
        UrjanetConnectLifecycleHandler handler = new UrjanetConnectLifecycleHandler();
        Canvas.Test.testCanvasLifecycle(handler, null);
    }

    @isTest
    static void testOverriddenAppValues() {
        // Test handler with some mock application context values
        Map<String, String> appValues = new Map<String, String>();
        appValues.put(Canvas.Test.KEY_CANVAS_URL, 'https://test.urjanet.com/myAppPath');
        appValues.put(Canvas.Test.KEY_VERSION, '1.0');

        // Test handler with some mock environment context values
        Map<String, String> envValues = new Map<String, String>();
        envValues.put(Canvas.Test.KEY_DISPLAY_LOCATION, 'Chatter');
        envValues.put(Canvas.Test.KEY_LOCATION_URL, 'https://test.salesforce.com/_ui/core/chatter/ui/ChatterPage');

        Canvas.RenderContext mock = Canvas.Test.mockRenderContext(appValues, envValues);
        UrjanetConnectLifecycleHandler handler = new UrjanetConnectLifecycleHandler();
        Canvas.Test.testCanvasLifecycle(handler, mock);
        System.assertEquals('https://test.urjanet.com/myAppPath', handler.app.getCanvasUrl(), 'urls do not match');
    }

    @isTest
    static void testOverriddenEnvironmentValues() {
        // Test handler with some mock application context values
        Map<String, String> appValues = new Map<String, String>();
        appValues.put(Canvas.Test.KEY_CANVAS_URL, 'https://test.urjanet.com/myAppPath');
        appValues.put(Canvas.Test.KEY_VERSION, '1.0');

        // Test handler with some mock environment context values
        Map<String, String> envValues = new Map<String, String>();
        envValues.put(Canvas.Test.KEY_DISPLAY_LOCATION, 'Chatter');
        envValues.put(Canvas.Test.KEY_LOCATION_URL, 'https://test.salesforce.com/_ui/core/chatter/ui/ChatterPage');
        UrjanetConnectLifecycleHandler handler = new UrjanetConnectLifecycleHandler();
        Canvas.RenderContext mock = Canvas.Test.mockRenderContext(appValues, envValues);
        // Directly update the mock RenderContext and set the custom parameters
        mock.getEnvironmentContext()
            .setParametersAsJSON('{\"one\":1,\"two\":2,\"bool\":true,\"path\":\"/canvas/salesforce\"}');
        Canvas.Test.testCanvasLifecycle(handler, mock);
        System.assertEquals(
            'https://test.urjanet.com/canvas/salesforce',
            handler.app.getCanvasUrl(),
            'urls do not match'
        );
    }
}