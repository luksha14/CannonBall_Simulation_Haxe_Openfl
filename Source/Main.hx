import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.text.TextField;
import openfl.text.TextFieldType;
import openfl.text.TextFormat;
import js.Lib;
import js.html.Window;
import openfl.display.SimpleButton;


class Main extends Sprite {
    // Input fields for user data
    private var angleInput:TextField;
    private var speedInput:TextField;
    private var heightInput:TextField;
    private var massInput:TextField;
    private var diameterInput:TextField;
    private var windSpeedInput:TextField;
    private var output:TextField;
    private var simulateButton:Sprite;
    private var backButton:Sprite;


	private var popupContainer:Sprite;
	private var popupInputX:TextField;
	private var popupInputY:TextField;

    // Ball and simulation variables
    private var ball:Sprite;
    private var blueBall:Sprite;
    private var velocityX:Float;
    private var velocityY:Float;
    private var blueVelocityX:Float;
    private var blueVelocityY:Float;
    private var maxHeight:Float;
    private var blueMaxHeight:Float = 0;
    private var startX:Float = 50;
    private var startY:Float;
    private var mass:Float;
	private var redTimeInAir:Float = 0;
	private var blueTimeInAir:Float = 0;
    private var simulationMode:Int = 1;

    // Ball states
    private var redBallOnGround:Bool = false;
    private var blueBallOnGround:Bool = false;

    // Ranges
    private var redRange:Float = 0;
    private var blueRange:Float = 0;

    // Constants for physics
    static var GRAVITY:Float = 9.81;
    static var CD:Float = 0.47;
    static var AIR_DENSITY:Float = 1.225;
    static var TIME_STEP:Float = 0.1;
    private var airResistance:Float;

    public function new() {
        super();
        stage.scaleMode = openfl.display.StageScaleMode.NO_SCALE;
        stage.align = openfl.display.StageAlign.TOP_LEFT;

        createSimulationMenu();
    }

    // Create simulation selection menu with buttons
    private function createSimulationMenu():Void {
        var menuLabel = new TextField();
        menuLabel.text = "Choose simulation:\n";
        menuLabel.x = 10;
        menuLabel.y = 10;

        menuLabel.width = 300;  
        menuLabel.height = 80;  

        var format = new TextFormat();
        format.size = 16;  
        format.align = "left";  
        menuLabel.setTextFormat(format);

        menuLabel.wordWrap = true;  
        menuLabel.autoSize = "left";  
        
        addChild(menuLabel);

        var button1 = createSimulationButton("1) Projectile with air resistance", 50);
        button1.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):Void {
            simulationMode = 1;
            startSimulation();
        });

        var button2 = createSimulationButton("2) Parallel simulation", 120);
        button2.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):Void {
            simulationMode = 2;
            startSimulation();
        });

		var button3 = createSimulationButton("3) Hit the Target", 190);
		button3.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):Void {
			simulationMode = 3;
			trace("Button clicked. Simulation mode set to: " + simulationMode);
			startSimulation();
			showPopup();
		});
    }

    // Create a simulation type button
    private function createSimulationButton(label:String, yPos:Int):Sprite {
        var button = new Sprite();
        button.graphics.beginFill(0x0078D4);
        button.graphics.drawRoundRect(0, 0, 300, 40, 15, 15);  // Increased width to 300
        button.graphics.endFill();
        button.x = 10;
        button.y = yPos;

        var text = new TextField();
        text.text = label;
        text.textColor = 0xFFFFFF;
        text.x = 10;
        text.y = 10;
        var format = new TextFormat();
        format.size = 16;
        text.setTextFormat(format);

        text.autoSize = "left"; 
        text.width = Math.min(text.textWidth + 20, 300);  // Ensure it doesn't overflow the button

        button.addChild(text);

        addChild(button);
        return button;
    }

    // Start the simulation by removing the menu and creating the input fields
    private function startSimulation():Void {
        // Remove old elements
        while (numChildren > 0) {
            removeChildAt(0);
        }
    
        // Create input fields for simulation
        createInputFields();
    
        // Create the buttons, but ensure event listeners are reattached
        createSimulateButton();
        createBackButton();
    }

    // Create input fields dynamically
    private function createInputFields():Void {
		// Input fields for user data
		angleInput = createInputField("Launch angle (degrees): ", 10);
		speedInput = createInputField("Initial speed (m/s): ", 50);
		heightInput = createInputField("Height (m): ", 90);
		massInput = createInputField("Mass (kg): ", 130);
		diameterInput = createInputField("Diameter (m): ", 170);
		windSpeedInput = createInputField("Wind speed (m/s): ", 210);
	
		// Create output field to the right of input fields
		output = new TextField();
		output.x = 400; 
		output.y = 10;  
		output.width = 400;
		output.height = 260;
		output.border = true;
		output.background = true;
		output.backgroundColor = 0xFFFFFF;
		output.multiline = true;
		output.wordWrap = true;
		addChild(output);
	}

    // Helper function to create an input field
    private function createInputField(labelText:String, yPos:Int):TextField {
		var label = new TextField();
        label.text = labelText;
        label.y = yPos;
        label.x = 10;

        label.width = 200;
        label.height = 30;

        var format = new TextFormat();
        format.size = 14;
        label.setTextFormat(format);

        label.autoSize = "left";

        addChild(label);

        var input = new TextField();
        input.type = TextFieldType.INPUT;
        input.border = true;
        input.background = true;
        input.backgroundColor = 0xFFFFFF;
        input.x = 200;
        input.y = yPos;
        input.width = 160; // Increased width for more space
        input.height = 30; // Increased height to fit text
        input.wordWrap = false; 
        input.multiline = false; // Disable scrolling for multiline text

        // Optional: Adjust font size to ensure it's fully visible
        var inputFormat = new TextFormat();
        inputFormat.size = 14; 
        input.setTextFormat(inputFormat);

        addChild(input);
        return input;
    }

    private function createSimulateButton():Void {
        simulateButton = new Sprite();
        simulateButton.graphics.beginFill(0x00CC00);
        simulateButton.graphics.drawRoundRect(0, 0, 120, 40, 15, 15);
        simulateButton.graphics.endFill();
        simulateButton.x = 10;
        simulateButton.y = 250;
        addChild(simulateButton);
        
        var buttonText = new TextField();
        buttonText.text = "Simulate";
        buttonText.x = 30;
        buttonText.y = 10;
        buttonText.textColor = 0xFFFFFF;
        buttonText.setTextFormat(new TextFormat("Arial", 16, 0xFFFFFF));
        simulateButton.addChild(buttonText);
        
        // Ensure the button is at the top layer
        setChildIndex(simulateButton, numChildren - 1);
        
        // Attach listener after creation
        simulateButton.addEventListener(MouseEvent.CLICK, onSimulateClick);
    }

    private function createBackButton():Void {
        backButton = new Sprite();
        backButton.graphics.beginFill(0xFF0000);
        backButton.graphics.drawRoundRect(0, 0, 120, 40, 15, 15);
        backButton.graphics.endFill();
        backButton.x = stage.stageWidth - 130;
        backButton.y = 10;
        addChild(backButton);
    
        var backButtonText = new TextField();
        backButtonText.text = "Back to Menu";
        backButtonText.x = 10;
        backButtonText.y = 10;
        backButtonText.textColor = 0xFFFFFF;
        backButtonText.setTextFormat(new TextFormat("Arial", 16, 0xFFFFFF));
        backButton.addChild(backButtonText);
    
        // Attach listener after creation
        backButton.addEventListener(MouseEvent.CLICK, onBackButtonClick);
    }

    private function onBackButtonClick(event:MouseEvent):Void {
        while (numChildren > 0) {
            removeChildAt(0);
        }

        createSimulationMenu();
    }

    // Create red ball (with air resistance)
    private function createRedBall():Void {
        ball = new Sprite();
        ball.graphics.beginFill(0xFF0000);
        ball.graphics.drawCircle(0, 0, 10);
        ball.graphics.endFill();
        ball.x = startX;
        ball.y = startY;
        addChild(ball);
    }

    // Create blue ball (no air resistance)
    private function createBlueBall():Void {
        blueBall = new Sprite();
        blueBall.graphics.beginFill(0x0000FF);
        blueBall.graphics.drawCircle(0, 0, 10);
        blueBall.graphics.endFill();
        blueBall.x = startX;
        blueBall.y = startY;
        addChild(blueBall);
    }

	private function showPopup():Void {
		trace("Popup opened.");
	
		// Create a semi-transparent background for the popup
		popupContainer = new Sprite();
		popupContainer.graphics.beginFill(0x000000, 0.5);
		popupContainer.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
		popupContainer.graphics.endFill();
		addChild(popupContainer);
	
		// Create a popup box
		var popupBox = new Sprite();
		popupBox.graphics.beginFill(0xFFFFFF);
		popupBox.graphics.drawRect(0, 0, 300, 200);
		popupBox.graphics.endFill();
		popupBox.x = (stage.stageWidth - 300) / 2;
		popupBox.y = (stage.stageHeight - 200) / 2;
		popupContainer.addChild(popupBox);
	
		// Add labels for X and Y coordinates
		var labelX = new TextField();
		labelX.text = "Enter X coordinate:";
		labelX.textColor = 0x000000;
		labelX.x = popupBox.x + 20;
		labelX.y = popupBox.y + 20;
		popupContainer.addChild(labelX);
	
		var labelY = new TextField();
		labelY.text = "Enter Y coordinate:";
		labelY.textColor = 0x000000;
		labelY.x = popupBox.x + 20;
		labelY.y = popupBox.y + 70;
		popupContainer.addChild(labelY);
	
		// Add input fields for X and Y coordinates
		popupInputX = createInputField("", 20);
		popupInputX.x = popupBox.x + 20;
		popupInputX.y = popupBox.y + 40;
		popupContainer.addChild(popupInputX);
	
		popupInputY = createInputField("", 20);
		popupInputY.x = popupBox.x + 20;
		popupInputY.y = popupBox.y + 90;
		popupContainer.addChild(popupInputY);
	
		// Add a "Create" button
		var createButton = new SimpleButton(
			createButtonGraphics(0xCCCCCC),
			createButtonGraphics(0xAAAAAA),
			createButtonGraphics(0x999999),
			createButtonGraphics(0xCCCCCC)
		);
		createButton.x = popupBox.x + 100;
		createButton.y = popupBox.y + 140;
		createButton.addEventListener(MouseEvent.CLICK, onCreateButtonClick);
		popupContainer.addChild(createButton);
	
		var buttonText = new TextField();
		buttonText.text = "Create";
		buttonText.textColor = 0x000000;
		buttonText.width = 60;
		buttonText.height = 20;
		buttonText.x = createButton.x + 10;
		buttonText.y = createButton.y + 5;
		popupContainer.addChild(buttonText);
	}

	private function createButtonGraphics(color:Int):Sprite {
		var sprite = new Sprite();
		sprite.graphics.beginFill(color);
		sprite.graphics.drawRect(0, 0, 80, 30);
		sprite.graphics.endFill();
		return sprite;
	}

	private function onCreateButtonClick(event:MouseEvent):Void {
		var xCoord:Float = Std.parseFloat(popupInputX.text);
		var yCoord:Float = Std.parseFloat(popupInputY.text);

		if (!Math.isNaN(xCoord) && !Math.isNaN(yCoord)) {
			removeChild(popupContainer); // Close the popup
			popupContainer = null;
			createTarget(xCoord, yCoord); // Create the target at the specified coordinates
		} else {
			trace("Invalid input. Please enter valid coordinates.");
		}
	}

	private function createTarget(x:Float, y:Float):Void {
		if (x <= 0 || y < 0) {
			trace("Please enter valid target coordinates.");
			return;
		}

		var target = new Sprite();
		target.graphics.beginFill(0x070707); 
		target.graphics.drawCircle(0, 0, 5); // Radius of 5 pixels
		target.graphics.endFill();

		// Position the target at the given coordinates
		target.name = "target";
		target.x = startX + x * METERS_TO_PIXELS;
		target.y = stage.stageHeight - y * METERS_TO_PIXELS; // Convert Y to screen coordinates
		addChild(target);
	}

	private function checkCollision(ball:Sprite, target:Sprite):Bool {
    // Get the center coordinates of the ball and target
		var ballCenterX:Float = ball.x;
		var ballCenterY:Float = ball.y;
		var targetCenterX:Float = target.x;
		var targetCenterY:Float = target.y;

		// Calculate the distance between the centers of the ball and target
		var distance:Float = Math.sqrt(Math.pow(ballCenterX - targetCenterX, 2) + Math.pow(ballCenterY - targetCenterY, 2));

		// Check if the distance is less than or equal to the sum of their radii
		return distance <= 15; // Assuming ball radius is 10 and target radius is 5
	}

    // Update simulation on each frame
    static var METERS_TO_PIXELS:Float = 1.6;

    private function onEnterFrame(event:Event):Void {
		if (simulationMode == 1) {
			updateRedBall();
			if (redBallOnGround) {
				removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				output.text += "\nRed ball (with air resistance):\n";
				output.text += "Range: " + Std.string(Math.round(redRange * 100) / 100) + " m\n";
				output.text += "Max height: " + Std.string(Math.round(maxHeight * 100) / 100) + " m\n";
				output.text += "Time in air: " + Std.string(Math.round(redTimeInAir * 100) / 100) + " s\n";
			}
		} else if (simulationMode == 2) {
			updateBlueBall();
			updateRedBall();
			if (redBallOnGround && blueBallOnGround) {
				removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				output.text += "\nRed ball (with air resistance):\n";
				output.text += "Range: " + Std.string(Math.round(redRange * 100) / 100) + " m\n";
				output.text += "Max height: " + Std.string(Math.round(maxHeight * 100) / 100) + " m\n";
				output.text += "Time in air: " + Std.string(Math.round(redTimeInAir * 100) / 100) + " s\n";
				output.text += "\nBlue ball (no air resistance):\n";
				output.text += "Range: " + Std.string(Math.round(blueRange * 100) / 100) + " m\n";
				output.text += "Max height: " + Std.string(Math.round(blueMaxHeight * 100) / 100) + " m\n";
				output.text += "Time in air: " + Std.string(Math.round(blueTimeInAir * 100) / 100) + " s\n";
			}
		} else if (simulationMode == 3) {
			updateRedBall();
		
			// Find the target by name
			var target:Sprite = null;
			for (i in 0...numChildren) {
				var child = getChildAt(i);
				if (child.name == "target") {
					target = cast(child, Sprite);
					break;
				}
			}
		
			if (target != null && checkCollision(ball, target)) {
				removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				output.text += "\nCongratulations! You hit the target!\n";
				return;
			}
		
			if (redBallOnGround) {
				removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		
				// Calculate the distance from the target
				var targetX:Float = target.x;
				var targetY:Float = target.y;
				var ballX:Float = ball.x;
				var ballY:Float = ball.y;
		
				var distanceToTarget:Float = Math.sqrt(Math.pow(ballX - targetX, 2) + Math.pow(ballY - targetY, 2));
		
				output.text += "\nYou missed the target. Try again!\n";
				output.text += "Distance to target: " + Std.string(Math.round(distanceToTarget * 100) / 100) + " pixels\n";
				output.text += "Red ball range: " + Std.string(Math.round(redRange * 100) / 100) + " m\n";
			}
		}
	}

	private function calculateAirResistance(diameter:Float):Float {
        var radius:Float = diameter / 2.0;
        var area:Float = Math.PI * Math.pow(radius, 2);
        return 0.5 * CD * AIR_DENSITY * area;
    }

    // Update red ball with air resistance
    private function updateRedBall():Void {
		if (redBallOnGround) {
			return;
		}
		var velocity:Float = Math.sqrt(velocityX * velocityX + velocityY * velocityY);
		var dragForce:Float = airResistance * Math.pow(velocity, 2);
		var dragForceX:Float = dragForce * (velocityX / velocity);
		var dragForceY:Float = dragForce * (velocityY / velocity);
		var windAccelerationX:Float = Std.parseFloat(windSpeedInput.text) / mass;
		var accelerationX:Float = (-dragForceX / mass) + windAccelerationX;
		var accelerationY:Float = (-dragForceY / mass) - GRAVITY;
	
		velocityX += accelerationX * TIME_STEP;
		velocityY += accelerationY * TIME_STEP;
	
		ball.x += velocityX * TIME_STEP * METERS_TO_PIXELS;
		ball.y -= velocityY * TIME_STEP * METERS_TO_PIXELS;
	
		var currentRange:Float = (ball.x - startX) / METERS_TO_PIXELS;
		var currentHeight:Float = (stage.stageHeight - ball.y) / METERS_TO_PIXELS; 
	
		if (currentHeight > maxHeight) {
			maxHeight = currentHeight;
		}
		redTimeInAir += TIME_STEP;
	
		redRange = currentRange;
	
		if (ball.y >= stage.stageHeight) { // Check if ball hits the ground
			redBallOnGround = true;
			ball.y = stage.stageHeight;
			velocityX = 0;
			velocityY = 0;
		}
	}

    // Update blue ball (no air resistance)
    private function updateBlueBall():Void {
		blueVelocityY -= GRAVITY * TIME_STEP;
	
		var windAccelerationX:Float = Std.parseFloat(windSpeedInput.text) / mass;
		blueVelocityX += windAccelerationX * TIME_STEP;
	
		blueBall.x += blueVelocityX * TIME_STEP * METERS_TO_PIXELS;
		blueBall.y -= blueVelocityY * TIME_STEP * METERS_TO_PIXELS;
	
		var currentRange:Float = (blueBall.x - startX) / METERS_TO_PIXELS;
		var currentHeight:Float = (startY - blueBall.y) / METERS_TO_PIXELS; 
	
		if (currentHeight > blueMaxHeight) {
			blueMaxHeight = currentHeight;
		}
	
		blueRange = currentRange;
		blueTimeInAir += TIME_STEP;
	
		if (blueBall.y >= stage.stageHeight) { // Check if ball hits the ground
			blueBallOnGround = true;
			blueBall.y = stage.stageHeight;
			blueVelocityX = 0;
			blueVelocityY = 0;
		}
	}

    private function onSimulateClick(event:MouseEvent):Void {
		trace("Simulate button clicked.");
		// Parse user inputs
		var angle:Float = Std.parseFloat(angleInput.text);
		var speed:Float = Std.parseFloat(speedInput.text);
		var height:Float = Std.parseFloat(heightInput.text);
		mass = Std.parseFloat(massInput.text);
		var diameter:Float = Std.parseFloat(diameterInput.text);
		var windSpeed:Float = Std.parseFloat(windSpeedInput.text);
	
		// Display input values
		var result:String = "Inputs:\n";
		result += "Angle: " + angle + "°\n";
		result += "Initial Speed: " + speed + " m/s\n";
		result += "Height: " + height + " m\n";
		result += "Mass: " + mass + " kg\n";
		result += "Diameter: " + diameter + " m\n";
		result += "Wind speed: " + windSpeed + " m/s\n";
	
		// Initialize output text field
		if (output == null) {
			output = new TextField();
			output.width = 400;
			output.height = 200;
			output.x = 10;
			output.y = 300;
			addChild(output);
		}
		output.text = result;
	
		// Calculate starting position
		startY = Math.max(stage.stageHeight - (height * METERS_TO_PIXELS), 0);
		var radianAngle:Float = angle * Math.PI / 180;
		airResistance = calculateAirResistance(diameter);
	
		// Initial velocities
		velocityX = speed * Math.cos(radianAngle);
		velocityY = speed * Math.sin(radianAngle);
		blueVelocityX = velocityX;
		blueVelocityY = velocityY;
	
		// Reset simulation variables
		redBallOnGround = false;
		blueBallOnGround = false;
		redRange = 0;
		blueRange = 0;
		redTimeInAir = 0;
		blueTimeInAir = 0;
		maxHeight = height; 
		blueMaxHeight = height;
	
		// Remove old balls (if any)
		if (ball != null) {
			removeChild(ball);
			ball = null;
		}
		if (blueBall != null) {
			removeChild(blueBall);
			blueBall = null;
		}
	
		// Create new balls
		createRedBall();
		if (simulationMode == 2) {
			createBlueBall();
		}
	
		// Add target logic for mode 3
		if (simulationMode == 3) {
    		if (numChildren <= 1) {
				trace("Error: Target not created. Please create a target first.");
				return;
			}
		}
	
		// Start simulation
		removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		addEventListener(Event.ENTER_FRAME, onEnterFrame);
	}
}
