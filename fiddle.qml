import QtQuick 2.0
import MuseScore 1.0

MuseScore {
      menuPath: "Plugins.Violin tabs"
// tab a note
    function tabNotes(notes, text) {
        
      var fingerings = [ 
      "0\nG", "1L\nG", "1\nG", "2L\nG", "2\nG", "3\nG", "3H\nG", 
      "0\nD", "1L\nD", "1\nD", "2L\nD", "2\nD", "3\nD", "3H\nD", 
      "0\nA", "1L\nA", "1\nA", "2L\nA", "2\nA", "3\nA", "3H\nA", 
      "0\nE", "1L\nE", "1\nE", "2L\nE", "2\nE", "3\nE", "3H\nE", "4\nE", 
      "1", "1", "2", "2", "3", "3",
      ]
        
       
        var tuning = fingerings
        var harpkey = 55 //(for the violin)
        for (var i = 0; i < notes.length; i++) {
            var sep = "\n"; // change to "," if you want them horizontally
            if ( i > 0 )
                text.text = fingerings[notes[i].pitch - harpkey];
            
            if (typeof notes[i].pitch === "undefined") // just in case
                return
            if (typeof tuning[notes[i].pitch - harpkey] === "undefined")
                    text.text = "X";
            else
                  text.text = tuning[notes[i].pitch - harpkey] + text.text;

        }
    }





//main function ----------------




      function main()
      {
      console.log("main function running")
      
 
      

// variables declaration
      var textposition= 12 //set to 10 for below staff, 0 above and -2 for higher 
      var startStaff;
      var endStaff;
      var endTick;
      var fullScore = false;




      if (typeof curScore === 'undefined')
            Qt.quit();
      var cursor = curScore.newCursor();
      console.log("textposition set to "+textposition)

      cursor.rewind(1);

      if (!cursor.segment) 
            { // no selection
            fullScore = true;
            startStaff = 0; // start with 1st staff
            endStaff  = curScore.nstaves - 1; // and end with last
            }
      else 
           {
            startStaff = cursor.staffIdx;
            cursor.rewind(2);
            if (cursor.tick == 0) {
                // this happens when the selection includes
                // the last measure of the score.
                // rewind(2) goes behind the last segment (where
                // there's none) and sets tick=0
                endTick = curScore.lastSegment.tick + 1;
            } else {
                endTick = cursor.tick;
            }
            endStaff   = cursor.staffIdx;
            }
      console.log(startStaff + " - " + endStaff + " - " + endTick)


//we apply to our sheet :
        for (var staff = startStaff; staff <= endStaff; staff++) {
            for (var voice = 0; voice < 4; voice++) {
                cursor.rewind(1); // beginning of selection
                cursor.voice    = voice;
                cursor.staffIdx = staff;
                
                if (fullScore)  // no selection
                    cursor.rewind(0); // beginning of score
                    
                    while (cursor.segment && (fullScore || cursor.tick < endTick)) {
                        if (cursor.element && cursor.element.type == Element.CHORD) {
                            var text = newElement(Element.STAFF_TEXT);
                            
                            var graceChords = cursor.element.graceNotes;
                            for (var i = 0; i < graceChords.length; i++) {
                                // iterate through all grace chords
                                var notes = graceChords[i].notes;
                                tabNotes(notes, text);
                                // there seems to be no way of knowing the exact horizontal pos.
                                // of a grace note, so we have to guess:
                                text.pos.x = -2.5 * (graceChords.length - i);
                                text.pos.y = textposition;

                                cursor.add(text);
                                // new text for next element
                                text  = newElement(Element.STAFF_TEXT);
                            }
                            
                            var notes = cursor.element.notes;
                            tabNotes(notes, text);
                            text.pos.y = textposition;
                            console.log("position is "+text.tick)
                            if ((voice == 0) && (notes[0].pitch > 83))
                                text.pos.x = 1;
                            cursor.add(text);
                        } // end if CHORD
                        cursor.next();
                    } // end while segment
            } // end for voice
        } // end for staff


      }   


//on run --------------------
      onRun: {
            main()
            Qt.quit()
            }      



      }
