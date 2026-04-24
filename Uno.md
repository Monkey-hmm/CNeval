Big Picture

These Arduino lab programs are all built on one simple pattern:

Input → Processing → Output

Input: button, sensor, analog value, ultrasonic sensor

Processing: if, for, while, switch, counting, comparison

Output: LED ON/OFF, serial monitor print, buzzer, etc.


Arduino is basically a tiny computer that keeps repeating the same work forever.

Every Arduino program has:

void setup()
{
   // runs once
}

void loop()
{
   // runs again and again forever
}

Think:

setup() = preparation

loop() = actual repeated work



---

Core Building Blocks

1. pinMode()

Tells Arduino whether a pin is input or output.

pinMode(13, OUTPUT);
pinMode(2, INPUT);


---

2. digitalWrite()

Used for ON/OFF signals

digitalWrite(13, HIGH); // ON
digitalWrite(13, LOW);  // OFF


---

3. digitalRead()

Reads button state

int x = digitalRead(2);

Returns:

HIGH

LOW



---

4. analogRead()

Reads sensor values

int val = analogRead(A0);

Range:

0 to 1023

because Arduino UNO uses 10-bit ADC


---

5. delay()

Pause execution

delay(1000);

means 1000 ms = 1 sec


---

6. Serial Monitor

Used to print values

Serial.begin(9600);
Serial.println(value);


---

Example Walkthroughs


---

1. Blink LED

Goal

LED ON → wait → OFF → wait


---

Code

void setup()
{
  pinMode(13, OUTPUT);
}

void loop()
{
  digitalWrite(13, HIGH);
  delay(1000);

  digitalWrite(13, LOW);
  delay(1000);
}


---

Logic

Pin 13 = LED
HIGH = glow
LOW = stop glowing

This is the easiest Arduino program.


---

2. Read Analog Voltage

Goal

Read sensor value from potentiometer/LDR/etc.


---

Code

void setup()
{
  Serial.begin(9600);
}

void loop()
{
  int sensor = analogRead(A0);

  float voltage = sensor * (5.0 / 1023.0);

  Serial.println(voltage);

  delay(500);
}


---

Important Formula

V = \text{Reading} \times \frac{5.0}{1023.0}

Because:

0 → 0V

1023 → 5V



---

3. Button Controls LED

Goal

Press button → LED ON

Release → OFF


---

Code

void setup()
{
  pinMode(2, INPUT);
  pinMode(13, OUTPUT);
}

void loop()
{
  int button = digitalRead(2);

  if(button == HIGH)
    digitalWrite(13, HIGH);
  else
    digitalWrite(13, LOW);
}


---

4. State Change Detection

Goal

Count how many times button was pressed


---

Idea

Need:

current state

previous state


Only count when:

LOW → HIGH

This avoids multiple counting.


---

Core Logic

if(buttonState != lastButtonState)
{
   if(buttonState == HIGH)
      count++;
}


---

5. Arrays

Goal

Store multiple LED pins


---

Code

int ledPins[] = {2,3,4,5};

void setup()
{
  for(int i=0;i<4;i++)
    pinMode(ledPins[i], OUTPUT);
}


---

Why?

Instead of writing:

pinMode(2, OUTPUT);
pinMode(3, OUTPUT);
pinMode(4, OUTPUT);

use array + loop.

Cleaner.


---

6. For Loop Iteration

Goal

LED chasing effect

LED1 → LED2 → LED3 → LED4


---

Code

for(int i=2;i<=5;i++)
{
   digitalWrite(i, HIGH);
   delay(200);
   digitalWrite(i, LOW);
}


---

7. If Statement Conditional

Goal

If sensor value > threshold → LED ON


---

Code

int sensor = analogRead(A0);

if(sensor > 500)
   digitalWrite(13, HIGH);
else
   digitalWrite(13, LOW);


---

8. Switch Case

Goal

Choose action based on value


---

Code

switch(value)
{
  case 1:
    LED1 ON;
    break;

  case 2:
    LED2 ON;
    break;

  default:
    all OFF;
}


---

Why?

Better than too many if else


---

9. Switch Case 2 (Serial Input)

Goal

Receive characters from serial monitor

Example:

type a → LED ON

type b → LED OFF



---

Code

char ch;

if(Serial.available())
{
   ch = Serial.read();

   switch(ch)
   {
      case 'a':
        digitalWrite(13, HIGH);
        break;

      case 'b':
        digitalWrite(13, LOW);
        break;
   }
}


---

10. While Statement

Goal

Keep calibrating sensor while button pressed


---

Code Idea

while(digitalRead(buttonPin) == HIGH)
{
   sensor = analogRead(A0);
}

Means:

As long as condition true → keep running


---

11. Ultrasonic Sensor

Goal

Detect distance of object

Using:

HC-SR04 Ultrasonic Sensor


---

Working

TRIG pin sends sound wave
ECHO pin receives reflected wave
Time taken → distance


---

Formula

\text{Distance} = \frac{\text{Time} \times \text{Speed of Sound}}{2}

Division by 2 because:

go + return


---

Quick Recall (Exam Memory)

setup() → once

loop() → forever

digitalWrite() → ON/OFF

digitalRead() → button

analogRead() → sensor (0–1023)

for → repeat fixed times

while → repeat while condition true

if → decision making

switch → multiple choices

ultrasonic → time → distance



---

One-Line Summary

Arduino programs are just repeated cycles of reading inputs, applying logic, and controlling outputs.
