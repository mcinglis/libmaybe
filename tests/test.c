
#include <stdio.h>

#include <libmacro/assert.h>
#include <libbase/int.h>
#include <libbase/ptr.h>

#include "maybe/int.h"
#include "maybe/ptr.h"


static
void
test_maybe_int( void )
{
    Maybe_int x = { .value = 5 };
    Maybe_int y = { .value = 78 };
    Maybe_int z = { .nothing = true };

    ASSERT(
        !maybe_int__is_nothing( x ),
        maybe_int__is_value( x ),
        !maybe_int__is_nothing( y ),
        maybe_int__is_value( y ),
        maybe_int__is_nothing( z ),
        !maybe_int__is_value( z ),
        maybe_int__value_or( x, 888 ) == x.value,
        maybe_int__value_or( y, 888 ) == y.value,
        maybe_int__value_or( z, 888 ) == 888,
        maybe_int__equal( maybe_int__applied( x, int__succ ),
                          ( Maybe_int ){ .value = x.value + 1 } ),
        maybe_int__equal( maybe_int__applied2( x, y, int__add ),
                          ( Maybe_int ){ .value = x.value + y.value } ),
        maybe_int__equal( maybe_int__applied2( x, z, int__sub ),
                          ( Maybe_int ){ .nothing = true } ),
        maybe_int__compare( x, y ) == LT,
        maybe_int__compare( y, x ) == GT,
        maybe_int__compare( x, z ) == GT,
        maybe_int__compare( x, x ) == EQ,
        maybe_int__equal( maybe_int__min2( x, y ), x ),
        maybe_int__is_nothing( maybe_int__min( x, y, z ) ),
        maybe_int__equal( maybe_int__max( x, y, z ), y )
    );
}


static
void
test_maybe_ptr( void )
{
    Maybe_ptr x = { .value = &( char[] ){ 'a', 'b', 'c' } };
    Maybe_ptr y = { .value = NULL };
    Maybe_ptr z = { .nothing = true };
    int const a = 123;

    ASSERT(
        !maybe_ptr__is_nothing( x ),
        maybe_ptr__is_value( x ),
        !maybe_ptr__is_nothing( y ),
        maybe_ptr__is_value( y ),
        maybe_ptr__is_nothing( z ),
        !maybe_ptr__is_value( z ),
        maybe_ptr__value_or( x, &a ) == x.value,
        maybe_ptr__value_or( y, &a ) == y.value,
        maybe_ptr__value_or( z, &a ) == &a
    );
}


int
main( void )
{
    test_maybe_int();
    test_maybe_ptr();
    printf( "All assertions passed!\n" );
}

