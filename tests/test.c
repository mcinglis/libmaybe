
#include <stdio.h>

#include <libmacro/assert.h>

#include <libbase/ulong.h>
#include <libbase/intmax.h>

#include "../maybe-ulong.h"
#include "../maybe-intmax.h"
#include "../maybe-ptr-ptr-char.h"


static
void
test_maybe_ulong( void )
{
    Maybe_ulong x = { .value = 5 };
    Maybe_ulong y = { .value = 78 };
    Maybe_ulong z = { .nothing = true };

    ASSERT(
        !maybe_ulong__is_nothing( x ),
        maybe_ulong__is_value( x ),
        !maybe_ulong__is_nothing( y ),
        maybe_ulong__is_value( y ),
        maybe_ulong__is_nothing( z ),
        !maybe_ulong__is_value( z ),
        maybe_ulong__value_or( x, 888 ) == x.value,
        maybe_ulong__value_or( y, 888 ) == y.value,
        maybe_ulong__value_or( z, 888 ) == 888,
        maybe_ulong__equal( maybe_ulong__applied( x, ulong__succ ),
                          ( Maybe_ulong ){ .value = x.value + 1 } ),
        maybe_ulong__equal( maybe_ulong__applied2( x, y, ulong__add ),
                          ( Maybe_ulong ){ .value = x.value + y.value } ),
        maybe_ulong__equal( maybe_ulong__applied2( x, z, ulong__sub ),
                          ( Maybe_ulong ){ .nothing = true } ),
        maybe_ulong__compare( x, y ) == LT,
        maybe_ulong__compare( y, x ) == GT,
        maybe_ulong__compare( x, z ) == GT,
        maybe_ulong__compare( x, x ) == EQ,
        maybe_ulong__equal( maybe_ulong__min2( x, y ), x ),
        maybe_ulong__is_nothing( maybe_ulong__min( x, y, z ) ),
        maybe_ulong__equal( maybe_ulong__max( x, y, z ), y ),
        maybe_ulong__equal(
                maybe_ulong__clamp( ( Maybe_ulong ){ .nothing = true },
                                    ( Maybe_ulong ){ .value = 35 },
                                    ( Maybe_ulong ){ .value = 78 } ),
                ( Maybe_ulong ){ .value = 35 } ),
        maybe_ulong__equal(
                maybe_ulong__clamp( ( Maybe_ulong ){ .value = 0 },
                                    ( Maybe_ulong ){ .value = 35 },
                                    ( Maybe_ulong ){ .value = 78 } ),
                ( Maybe_ulong ){ .value = 35 } ),
        maybe_ulong__equal(
                maybe_ulong__clamp( ( Maybe_ulong ){ .value = 56 },
                                    ( Maybe_ulong ){ .value = 35 },
                                    ( Maybe_ulong ){ .value = 78 } ),
                ( Maybe_ulong ){ .value = 56 } ),
        maybe_ulong__equal(
                maybe_ulong__clamp( ( Maybe_ulong ){ .value = 978 },
                                    ( Maybe_ulong ){ .value = 35 },
                                    ( Maybe_ulong ){ .value = 78 } ),
                ( Maybe_ulong ){ .value = 78 } )
    );
}


static
void
test_maybe_intmax( void )
{
    Maybe_intmax x = { .value = 5 };
    Maybe_intmax y = { .value = 78 };
    Maybe_intmax z = { .nothing = true };

    ASSERT(
        !maybe_intmax__is_nothing( x ),
        maybe_intmax__is_value( x ),
        !maybe_intmax__is_nothing( y ),
        maybe_intmax__is_value( y ),
        maybe_intmax__is_nothing( z ),
        !maybe_intmax__is_value( z ),
        maybe_intmax__value_or( x, 888 ) == x.value,
        maybe_intmax__value_or( y, 888 ) == y.value,
        maybe_intmax__value_or( z, 888 ) == 888,
        maybe_intmax__equal( maybe_intmax__applied( x, intmax__succ ),
                          ( Maybe_intmax ){ .value = x.value + 1 } ),
        maybe_intmax__equal( maybe_intmax__applied2( x, y, intmax__add ),
                          ( Maybe_intmax ){ .value = x.value + y.value } ),
        maybe_intmax__equal( maybe_intmax__applied2( x, z, intmax__sub ),
                          ( Maybe_intmax ){ .nothing = true } ),
        maybe_intmax__compare( x, y ) == LT,
        maybe_intmax__compare( y, x ) == GT,
        maybe_intmax__compare( x, z ) == GT,
        maybe_intmax__compare( x, x ) == EQ,
        maybe_intmax__equal( maybe_intmax__min2( x, y ), x ),
        maybe_intmax__is_nothing( maybe_intmax__min( x, y, z ) ),
        maybe_intmax__equal( maybe_intmax__max( x, y, z ), y ),
        maybe_intmax__equal(
                maybe_intmax__clamp( ( Maybe_intmax ){ .nothing = true },
                                     ( Maybe_intmax ){ .value = 35 },
                                     ( Maybe_intmax ){ .value = 78 } ),
                ( Maybe_intmax ){ .value = 35 } ),
        maybe_intmax__equal(
                maybe_intmax__clamp( ( Maybe_intmax ){ .value = -34 },
                                     ( Maybe_intmax ){ .value = 35 },
                                     ( Maybe_intmax ){ .value = 78 } ),
                ( Maybe_intmax ){ .value = 35 } ),
        maybe_intmax__equal(
                maybe_intmax__clamp( ( Maybe_intmax ){ .value = 56 },
                                     ( Maybe_intmax ){ .value = 35 },
                                     ( Maybe_intmax ){ .value = 78 } ),
                ( Maybe_intmax ){ .value = 56 } ),
        maybe_intmax__equal(
                maybe_intmax__clamp( ( Maybe_intmax ){ .value = 978 },
                                     ( Maybe_intmax ){ .value = 35 },
                                     ( Maybe_intmax ){ .value = 78 } ),
                ( Maybe_intmax ){ .value = 78 } )
    );
}


static
void
test_maybe_ptr_ptr_char( void )
{
    Maybe_ptr_ptr_char x = { .value = ( char const * [] ){
                                          ( char[] ){ 'a', 'b', 'c' },
                                          ( char[] ){ 'd', 'e', 'f' },
                                          ( char[] ){ 'g', 'h', 'i' } } };
    Maybe_ptr_ptr_char y = { .value = NULL };
    Maybe_ptr_ptr_char z = { .nothing = true };
    char const * const * const as = ( char const * [] ){ "testing",
                                                         "this",
                                                         "array" };

    ASSERT(
        !maybe_ptr_ptr_char__is_nothing( x ),
        maybe_ptr_ptr_char__is_value( x ),
        !maybe_ptr_ptr_char__is_nothing( y ),
        maybe_ptr_ptr_char__is_value( y ),
        maybe_ptr_ptr_char__is_nothing( z ),
        !maybe_ptr_ptr_char__is_value( z ),
        maybe_ptr_ptr_char__value_or( x, as ) == x.value,
        maybe_ptr_ptr_char__value_or( y, as ) == y.value,
        maybe_ptr_ptr_char__value_or( z, as ) == as,
        maybe_ptr_ptr_char__equal( x, x ),
        !maybe_ptr_ptr_char__equal( x, y ),
        !maybe_ptr_ptr_char__equal( x, z ),
        maybe_ptr_ptr_char__equal( z, ( Maybe_ptr_ptr_char ){
                                          .nothing = true } )
    );
}


int
main( void )
{
    test_maybe_ulong();
    printf( "All `ulong` assertions passed.\n" );
    test_maybe_intmax();
    printf( "All `intmax` assertions passed.\n" );
    test_maybe_ptr_ptr_char();
    printf( "All `ptr_ptr_char` assertions passed.\n" );
}

