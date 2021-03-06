OscSend xmit;
xmit.setHost("localhost", 12766);
xmit.startMsg("/sys/port, i");
xmit.addInt(55555);
xmit.startMsg("/sys/prefix, s");
xmit.addString("monome");

fun float next( float arg )
{
    return arg * 1.0594630943592953;
}

float tuner[8][16];

/* 440.0 => next => tuner[0][0]; */
/* 329.6 => next => tuner[1][0]; */
/* 246.9 => next => tuner[2][0]; */
466.16 => next => tuner[0][0];
349.23 => next => tuner[1][0];
261.63 => next => tuner[2][0];
196.0 => next => tuner[3][0];
146.8 => next => tuner[4][0];
110.0 => next => tuner[5][0];
82.4 => next => tuner[6][0];
61.73 => next => tuner[7][0];
for( 0 => int i; i < 8 ; i++ ) {
    for( 1 => int foo; foo < 16 ; foo++ ) {
        next(tuner[i][foo - 1]) => tuner[i][foo];
    }
}

ADSR monome[8][16];
for( 0 => int y; y < 8 ; y++ ) {
    for( 0 => int x; x < 16 ; x++ ) {
        SinOsc a;
        ADSR e;
        a => e => dac;
        e.set( 10::ms, 100::ms, .20, 2000::ms );
        e @=> monome[y][x];
        tuner[y][x]    => a.sfreq;
        0.2    => a.gain;
    }
}

OscRecv recv;
55555 => recv.port;
recv.listen();
recv.event("/monome/grid/key", "iii") @=> OscEvent oe;


while(true) {
    while(oe.nextMsg() != 0) {
        int x;
        int y;
        int state;
        oe.getInt() => x;
        oe.getInt() => y;
        oe.getInt() => state;

        xmit.startMsg("/monome/grid/led/set, iii");
        xmit.addInt(x);
        xmit.addInt(y);
        xmit.addInt(state);

        if (state) {
            monome[y][x].keyOn();
        } else {
            monome[y][x].keyOff();
        }
    oe => now;
    }
}
