# Meteor Shower Game

Welcome to the Meteor Shower game project! This repository contains the implementation of a computer architecture project that exercises the fundamentals of assembly language programming, peripherals, and interrupts.

## Gameplay

The following video shows how the game works.

https://github.com/user-attachments/assets/a1c74126-eda0-4393-842d-84d5d3a03689

## Objectives

The goal of this project is to simulate a game where a rover defends planet X by obtaining energy from good meteors and destroying bad meteors, which are robotic ships sent to invade the planet. The game interface includes a screen, a keyboard for game control, and a set of displays to show the rover's energy levels.

## Features

- **Multimedia Capabilities**: Utilizes the MediaCenter module of the simulator to define background images, play sounds and videos, and create image layers pixel by pixel.
- **Game Control**: The keyboard is used to start, pause, stop the game, and control the rover's position.
- **Visual Indicators**: Different game states (initial, playing, paused, ended) have different backgrounds or marquee texts to visually indicate the game state.
- **Rover Movement**: The rover moves left and right at the bottom of the screen.
- **Meteor Behavior**: Meteors start as small pixels from the top of the screen and grow larger as they descend. Good meteors are green, and bad meteors (enemy ships) are red.
- **Energy Management**: The rover's energy level is displayed and updated based on interactions with meteors.

## Implementation Highlights

- **Keyboard and Displays**: The keyboard is fully functional, detecting all key presses. Displays show the rover's energy in real-time.
- **Screen Routines**: Routines are implemented to draw and erase pixels and objects on the screen.
- **Rover Control**: Routines control the rover's movement based on keyboard input.
- **Meteor Management**: Processes handle the appearance, movement, and interactions of meteors.
- **Collision Detection**: Collision detection between meteors and the rover or missiles is implemented.
- **Energy Updates**: The rover's energy consumption and replenishment are managed using interrupts.<br>

## Project Documentation

For detailed information on the project, please refer to the [full project statement](https://github.com/pedroiralmeida/iac-proj/blob/main/Project_Statement.pdf).


