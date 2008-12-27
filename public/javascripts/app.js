$(document).ready(function() {
  $('.playlist').before("<span id='currently_playing'></span>");
  $('.playlist').before("<span id='next_song'></span>");
  
  soundManager.onload = function() {
    console.log('soundManager.onload has begun');
    // SM2 is ready to go!
    soundManager.debugMode = false;
    soundManager.consoleOnly = false;
    soundManager.multiShot = false;
    soundManager.playNext = true;
    
    function play_song(index){ 
      var current_song = soundManager.getSoundById('song_'+index);
      var jq_song = $(".playlist li:eq(" +index+ ")");
      // current_song.load();
      $(".playlist li.sm2_playing").each(function(){$(this).removeClass('sm2_playing');});
      $('#currently_playing').html('song'+index);
      $('#next_song').html('song_'+(index+1));
      // console.log("song: %s = %s", current_song.sID,  $('#next_song').html() );
      
      jq_song.addClass('sm2_playing');
      // current_song.options.onload(function(){jq_song.find('.duration').html(this.duration);})
      // current_song.options.whileplaying(function(){
      //   // $(".playlist li:eq(" +index+ ").playing").html(this.position);
      //   // $(".playlist li:eq(" +index+ ").duration").html(this.duration);
      //   console.log(this.position);
      // });
      
      soundManager.play('song_'+index);
      // current_song.play();
      // soundManager.load('song_'+(index+1));  //preload the next song
      console.log('playing song.');
    };
    
        
    $(".playlist li ").each(function(i){
         this.id = this.id + "song_" + i;
         var song_link = $(this).find('a');
         var song_url = song_link.attr('rel');
         // song_link.attr('rel', 'song_'+i);
         // $(this).contents('a').click(function(){});
         
         //iterate thru playlist, creating soundManager objects for all playable links
         if (soundManager.canPlayURL( song_url) ) {          
            soundManager.createSound({
              id: 'song_'+i,
              url: song_link.attr('rel'),
              volume: 95,
              playNext: true,
              consoleOnly: true,
              onfinish:function() {
                 console.log(this.sID+' finished playing');
                 play_song(i+1);
                 soundManager.play('song_'+(i+1));
               }
               // whileplaying: function() {                 
               //   // console.log('timing' + this.position+' / '+this.duration);
               // }
               
            });
          };
          
        
         $(this).click(function(){
           soundManager.stopAll();
            //pause if playing
           if ($(this).attr('class') == 'sm2_playing'){ 
             soundManager.pause('song_'+i);
             $(".playlist li.sm2_playing").each(function(){$(this).removeClass('sm2_playing');});
             $(".playlist li.sm2_paused").each(function(){$(this).removeClass('sm2_playing');});
             
             $(this).addClass('sm2_paused');
             console.debug($(this).attr('class')+' :pause song_'+i);
           }else {
              // console.debug(i+'-----'+$(this).next().html());
              $(this).removeClass('sm2_paused');
              play_song(i);
              console.debug( song_link.html() );
           };
          });
  
         });
  };
  
  
  // playlist behavior
  // $('.playlist_remove').click(function(){
  //   console.log("removing a song: %s", $(this).html());
  //   $.get($(this).attr('href'),'', function(){ $(this).hide('slow'); } );
  // });
  
  

});

