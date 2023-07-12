//
//  additions.h
//  CoreBlackbox
//
//  Created by Grady Haynes on 8/29/22.
//  Copyright © 2022 Grady Haynes. All rights reserved.
//

#ifndef additions_h
#define additions_h

uint16_t m6502_GET_ADDR(uint64_t);
uint8_t m6502_GET_DATA(uint64_t);
uint64_t m6502_SET_DATA(m6502_t *c, uint64_t, uint8_t);

#endif /* additions_h */
