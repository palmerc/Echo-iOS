#import "MTTransportWebSocket.h"



@implementation MTTransportWebSocket
- (dispatch_queue_t)onMessageQueue
{
    dispatch_queue_t dispatch_queue;
    if (_onMessageQueue == nil) {
        dispatch_queue = dispatch_get_main_queue();
    } else {
        dispatch_queue = _onMessageQueue;
    }

    return dispatch_queue;
}
- (dispatch_queue_t)onPongQueue
{
    dispatch_queue_t dispatch_queue;
    if (_onPongQueue == nil) {
        dispatch_queue = dispatch_get_main_queue();
    } else {
        dispatch_queue = _onPongQueue;
    }

    return dispatch_queue;
}
- (dispatch_queue_t)onFailQueue
{
    dispatch_queue_t dispatch_queue;
    if (_onFailQueue == nil) {
        dispatch_queue = dispatch_get_main_queue();
    } else {
        dispatch_queue = _onFailQueue;
    }

    return dispatch_queue;
}
- (dispatch_queue_t)onStateChangeQueue
{
    dispatch_queue_t dispatch_queue;
    if (_onStateChangeQueue == nil) {
        dispatch_queue = dispatch_get_main_queue();
    } else {
        dispatch_queue = _onStateChangeQueue;
    }

    return dispatch_queue;
}
@end
