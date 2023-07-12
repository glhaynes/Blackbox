//
//  m6502.c
//  CoreBlackbox
//
//  Created by Grady Haynes on 8/28/22.
//  Copyright © 2022 Grady Haynes. All rights reserved.
//

#define CHIPS_IMPL

#include "m6502.h"
#include "additions.h"

/// Extract 16-bit address bus from 64-bit pins
uint16_t m6502_GET_ADDR(uint64_t p) {
    return M6502_GET_ADDR(p);
}

/// Extract 8-bit data bus from 64-bit pins
uint8_t m6502_GET_DATA(uint64_t p) {
    return M6502_GET_DATA(p);
}

/// Merge 8-bit data bus value into 64-bit pins
uint64_t m6502_SET_DATA(m6502_t* c, uint64_t p, uint8_t d) {
    M6502_SET_DATA(p, d);
    c->PINS = p;
    return p;
}
