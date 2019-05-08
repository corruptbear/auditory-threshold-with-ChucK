class NDownOneUp
{
    SinOsc s;
    Hid hi;
    HidMsg msg;
    0 => int device;
    
    // get from command line
    //if( me.args() ) me.arg(0) => Std.atoi => device;

    if( !hi.openKeyboard( device ) ) me.exit();
    <<< "keyboard '" + hi.name() + "' ready", "" >>>;
    
    float stimulusSize; //initial size
    int N;

    0 => int nConsecutiveCorrectTrials;
    0 => int direction;
    0 => float threshold;
    0 => int nReversals;
    0 => int nTrials;
    int nTotalReversals;
    
    
    fun void trials(){
        s => dac;
        while (nReversals<nTotalReversals){
            if (trial()==1){
                nConsecutiveCorrectTrials++;               
            }
            else{
                0 => nConsecutiveCorrectTrials;                            
            }
            
            if (nConsecutiveCorrectTrials == 0){
                //reversal?
                if (direction == 1){
                    nReversals++;
                    if (nReversals>2){
                        threshold + stimulusSize => threshold;
                    }
                }
                stairUp();       
                -1 => direction;     
            }
            if (nConsecutiveCorrectTrials == N){
                0 => nConsecutiveCorrectTrials;
                //reversal?
                if (direction == -1){
                    nReversals++;
                    if (nReversals>2){
                        threshold + stimulusSize => threshold;
                    }
                }
                stairDown();     
                1 => direction;
            } 
            nTrials++;                                             
        } 
        threshold/(nTotalReversals-2) => threshold;
        displayResults();
                    
    }
    
    
    fun void stairDown(){        
    }
    
    fun void stairUp(){
    }
        
    fun int trial(){
        stimulus();
        displayQuestion();
        input() => int response;
        return match(response);  
    }
    
    fun int match(int response){
        return 0;
    }
    
    fun void displayQuestion(){
    }
    
    fun void displayResults(){
    }
    
    fun void stimulus(){       
    }
    
    fun int input()
    {
        hi => now;
        hi.recv(msg); //key down
        msg.key => int val;
        hi => now;
        hi.recv(msg); //key up
        return val;     
    }    
}

class NDownOneUpPitchDiscrimination extends NDownOneUp{
    
    float centralFreq; //Hz, central frequency
    float secondFreq;
   
    0.5 => float duration;
    0.05 => float pause;
    0.5 => float stairDownFactor;
    2 => float stairUpFactor;
        
    fun void displayQuestion(){
        <<<"currently at "+stimulusSize+" Hz,press Q if the first tone is higher,otherwise press P">>>;
    }
    
    fun void stimulus(){
        Math.random2(0,1) => int sign; //generates random integer in the range [min, max]
        if (sign==1){
            centralFreq + stimulusSize => secondFreq;}
        else{
            centralFreq - stimulusSize => secondFreq;}        
        1.0 => s.gain;
        centralFreq => s.freq;
        duration::second => now;
        0.0 => s.gain;
        pause::second => now;
        1.0 => s.gain;
        secondFreq => s.freq;
        duration::second => now;  
        0.0=>s.gain;
    }
    
    //check whether the response is positive
    fun int match(int response){
        if ((secondFreq - centralFreq > 0 && response==19) || (secondFreq - centralFreq < 0 && response==20)){
            return 1;}
        else{
            return 0;}       
    }
    
    fun void stairDown(){ 
        stimulusSize*stairDownFactor=> stimulusSize;               
    }
    
    fun void stairUp(){
        stimulusSize*stairUpFactor => stimulusSize;
    }
    
    fun void displayResults(){
        <<<"pitch discrimination threshold at "+ centralFreq +" Hz is "+threshold + " Hz"+" in "+nTrials+" trials">>>;         
    }        
}


NDownOneUpPitchDiscrimination x;
12 => x.stimulusSize;
3 => x.N;
10 => x.nTotalReversals;
440 => x.centralFreq;
x.trials();

