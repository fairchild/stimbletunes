$(document).ready(function() {
  
  soundManager.onload = function() {
    console.log('soundManager.onload has begun');
    // SM2 is ready to go!
    soundManager.debugMode = false;
    soundManager.consoleOnly = false;
    soundManager.multiShot = false;
    soundManager.playNext = true;
    
    play_next_song = function(index){ };  //TODO
    
    $(".playlist li ").each(function(i){
        this.id = this.id + "song_" + i;
         var song_link = $(this).find('a');
         var song_url = song_link.attr('rel');
         // song_link.attr('rel', 'song_'+i);
         // $(this).contents('a').click(function(){});
         
         //iterate thru playlist, creating soundManager objects for all playable links
         if (soundManager.canPlayURL( song_url) ) {          
            var mySound = soundManager.createSound({
              id: 'song_'+i,
              url: song_link.attr('rel'),
              volume: 95,
              playNext: true,
              consoleOnly: true,
              // onfinish: play_next_song(i);  TODO: encapuslate following code in a function
              onfinish: function() {
                  soundManager.play('song_'+i+1);
                  consoloe.debug("done playing song");
                  $(this).removeClass('sm2_playing');
                }
            });
            console.debug("created song_"+i);
            // mySound.play();
          };
          
        
         $(this).click(function(){
           soundManager.stopAll();
            //pause if playing
           if ($(this).attr('class') == 'sm2_playing'){ 
             soundManager.pause('song_'+i);
             $(".playlist li.sm2_playing").each(function(){$(this).removeClass('sm2_playing');});
             $(this).addClass('sm2_paused');
             
             console.debug($(this).attr('class')+' :pause song_'+i);
           }else {
              console.debug(i+'-----'+$(this).html());
              $(this).removeClass('sm2_paused');
              $(this).addClass('sm2_playing');
              soundManager.play('song_'+i);
              console.debug( song_link.html() );
           };
          });
  
         });
         // song_link.bind('click', function () {console.log('clicked a linke'); return false });
         
        
      
    
  //   var mySound = soundManager.createSound({
  //     id: 'aSound',
  //     url: 'http://localhost:4567/play/schiller%2FEightrack+Mind%2FHardly+Human%2F10+-+Sacrifice.mp3',
  //     volume: 90
  //   });
  //   mySound;
  };

});

