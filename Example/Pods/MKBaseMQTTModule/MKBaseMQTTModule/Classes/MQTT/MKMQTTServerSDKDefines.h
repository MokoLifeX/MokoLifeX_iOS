

#define MKMQTTValidStr(f)         (f!=nil && [f isKindOfClass:[NSString class]] && ![f isEqualToString:@""])
#define MKMQTTValidDict(f)        (f!=nil && [f isKindOfClass:[NSDictionary class]] && [f count]>0)
#define MKMQTTValidArray(f)       (f!=nil && [f isKindOfClass:[NSArray class]] && [f count]>0)
#define MKMQTTValidData(f)        (f!=nil && [f isKindOfClass:[NSData class]])

#ifndef MKMQTTBase_main_safe
#define MKMQTTBase_main_safe(block)\
if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(dispatch_get_main_queue())) == 0) {\
    block();\
} else {\
    dispatch_async(dispatch_get_main_queue(), block);\
}
#endif
