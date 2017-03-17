//This sketch is designed to control the shield after receiving signal from the Processing sketch through serial communication
//Upload this sketch on Arduino first before opening the Processing sketch

#include <AFMotor.h>

AF_DCMotor motor1(3);
AF_DCMotor motor2(4);

void setup()
{
    // Start up serial connection
    Serial.begin(9600); // baud rate
    Serial.flush();
}
     
void loop()
{
    String input = "";
     
    // Read any serial input
    while (Serial.available() > 0)
    {
        input += (char) Serial.read(); // Read in one char at a time
        delay(5); // Delay for 5 ms so the next char has time to be received
    }
    //motor1 is LEFT, motor2 is RIGHT
    if (input == "0")   //STOP
    {   
        motor1.run(RELEASE);
        motor2.run(RELEASE);
      
    }
   
    else if (input == "1")     //STRAIGHT
    {
       motor1.setSpeed(248); 
       motor1.run(FORWARD); 
       motor2.setSpeed(252);
       motor2.run(FORWARD); 
       
    }

      else if (input == "2")    //LEFT
      {
       motor1.setSpeed(210);//225
       motor1.run(FORWARD); 
       motor2.setSpeed(255);
       motor2.run(FORWARD); 
    }
    
    else if (input == "3")      //RIGHT  
    {
       motor1.setSpeed(255); 
       motor1.run(FORWARD); 
       motor2.setSpeed(220);//230
       motor2.run(FORWARD); 
    }

    else if (input == "4")
    {
       motor1.setSpeed(255); 
       motor1.run(FORWARD); 
       motor2.setSpeed(200);
       motor2.run(FORWARD); 
    }
}


