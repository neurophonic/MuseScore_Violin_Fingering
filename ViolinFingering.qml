//=============================================================================
//  Violin and Viola Fingering Plugin
//
//  Adds fingering for Violin and Viola to the score
//
//  Copyright (c) 2014 lalov
//                2016 HansPog & Christophe Corsi
//                2019 Johan Temmerman (jeetee)
//                2023 Joachim Schmitz (Jojo-Schmitz)
//				  2024 Nathan Pavey 
//=============================================================================
import QtQuick 2.2
import MuseScore 3.0

MuseScore {
	menuPath: "Plugins.Violin Fingering Modified"
	title: "Violin Fingering Modified"
	version: "4.0.1"
	description: "Adds fingering for Violin and Viola to the score"
	thumbnailName: "violin-fingering.png"
	categoryCode: "composing-arranging-tools"
	requiresScore: true

	onRun: {
		var textposition = 0.65;
		var startStaff;
		var endStaff;
		var endTick;
		var fullScore = false;

		//find out range to apply to, either selection or full score
		var cursor = curScore.newCursor();
		cursor.rewind(1); //start of selection
		if (!cursor.segment) { //no selection
			fullScore  = true;
			startStaff = 0; // start with 1st staff
			endStaff   = curScore.nstaves - 1; // and end with last
		}
		else {
			startStaff = cursor.staffIdx;
			cursor.rewind(2); //find end of selection
			if (cursor.tick == 0) {
				// this happens when the selection includes
				// the last measure of the score.
				// rewind(2) goes behind the last segment (where
				// there's none) and sets tick=0
				endTick = curScore.lastSegment.tick + 1;
			}
			else {
				endTick = cursor.tick;
			}
			endStaff = cursor.staffIdx;
		}
		console.log(startStaff + " - " + endStaff + " - " + endTick)

		curScore.startCmd()

		//loop over the selection
		for (var staff = startStaff; staff <= endStaff; staff++) {
			for (var voice = 0; voice < 4; voice++) {
				cursor.rewind(1); // beginning of selection
				cursor.voice    = voice;
				cursor.staffIdx = staff;

				if (fullScore) { // no selection
					cursor.rewind(0); // beginning of score
				}

				while (cursor.segment && (fullScore || cursor.tick < endTick)) {
					if (cursor.element && cursor.element.type == Element.CHORD) {
						var text = newElement(Element.STAFF_TEXT);
						text.autoplace = true;
						text.offsetX = textposition;
						text.align = 2;//Align.HCenter;
						
						var graceChords = cursor.element.graceNotes;
						for (var i = 0; i < graceChords.length; i++) {
							// iterate through all grace chords
							var notes = graceChords[i].notes;
							addFingerText(notes, text);
							// there seems to be no way of knowing the exact horizontal pos.
							// of a grace note, so we have to guess:
							text.offsetX = -2.5 * (graceChords.length - i);
							cursor.add(text);
							
							// new text for next element
							text  = newElement(Element.STAFF_TEXT);
							text.autoplace = true;
							text.offsetX = textposition;
							text.align = 2;//Align.HCenter;
						}

						var notes = cursor.element.notes;
						addFingerText(notes, text);
						cursor.add(text);
					} // end if CHORD
					cursor.next();
				} // end while segment
				
			} // end for voice
		} // end for staff

		curScore.endCmd()

		quit();
	}

	// match note with fingering text
	function addFingerText(notes, text) {
		var fingerings = [ 
			"0", "①", "1", "②", "2", "3", "3H", 
			"0", "①", "1", "②", "2", "3", "3H", 
			"0", "①", "1", "②", "2", "3", "3H", 
			"0", "①", "1", "②", "2", "3", "3H", 
			"0", "①", "1", "②", "2", "3", "3H", "4", 
			"1", "1", "2", "2", "3", "3",
		]
		var tuning = fingerings
		var lowestPitch = 48 //for the (alto)violin
		
		for (var i = 0; i < notes.length; i++) {
			var sep = "\n"; // change to "," if you want them horizontally
			if (i > 0) {
				text.text = fingerings[notes[i].pitch - lowestPitch];
			}
			
			if (typeof notes[i].pitch === "undefined") { // just in case
				return
			}
			if (typeof tuning[notes[i].pitch - lowestPitch] === "undefined") {
				text.text = "X";
			}
			else {
				text.text = tuning[notes[i].pitch - lowestPitch] + text.text;
			}
		}
	}

}
