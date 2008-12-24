$(document).ready(function() {
  
  soundManager.onload = function() {
    // SM2 is ready to go!
    soundManager.consoleOnly = true;
    soundManager.multiShot = false;
    soundManager.playNext = true;
    
    $(".playlist li ").each(function(i){
        this.id = this.id + "song_" + i;
         var song_link = $(this).contents('a');
         // song_link.attr('rel', 'song_'+i);
         $(this).contents('a').click(function(){});
        
         $(this).click(function(){
           soundManager.stopAll();
           $(".playlist li ").each(function(){$(this).removeClass('sm2_playing');});
           
           console.debug( song_link.attr('rel') );
           $(this).addClass('sm2_playing');
           var mySound = soundManager.createSound({
             id: 'song_'+i,
             url: song_link.attr('rel'),
             volume: 95
           });
           mySound.play();
         });
         // song_link.bind('click', function () {console.log('clicked a linke'); return false });
         
         
      });
      
    
  //   var mySound = soundManager.createSound({
  //     id: 'aSound',
  //     url: 'http://localhost:4567/play/schiller%2FEightrack+Mind%2FHardly+Human%2F10+-+Sacrifice.mp3',
  //     volume: 90
  //   });
  //   mySound;
  };

});

