public with sharing class QueueItemUtils {
    public static String getNamespaceWithDot() {
        return QueueItemUtils.class.getName().substringBefore('QueueItemUtils');
    }
}