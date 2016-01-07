module sbylib.core.manipulator.simplemover;

import sbylib.imports;

class SimpleMover : Manipulator {

	this(Entity entity) {
		super(entity);
	}

	override void Manipulate() {
		with(entity) {
			if ( Or ( &CurrentWindow.isKeyPressed, KeyButton.W)) {
				Pos = GetPos - 0.2 * GetVecZ;
			}
			if ( Or( &CurrentWindow.isKeyPressed, KeyButton.S)) {
				Pos = GetPos + 0.2 * GetVecZ;
			}
			if ( Or ( &CurrentWindow.isKeyPressed, KeyButton.A, KeyButton.Left)) {
				Pos = GetPos + 0.2 * GetVecX;
			}
			if ( Or( &CurrentWindow.isKeyPressed, KeyButton.D, KeyButton.Right)) {
				Pos = GetPos - 0.2 * GetVecX;
			}
			if ( Or ( &CurrentWindow.isKeyPressed, KeyButton.Up)) {
				Pos = GetPos + 0.2 * GetVecY;
			} 
			if ( Or( &CurrentWindow.isKeyPressed, KeyButton.Down)) {
				Pos = GetPos - 0.2 * GetVecY;
			}
		}
	}
}