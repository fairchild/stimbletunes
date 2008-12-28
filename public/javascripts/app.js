$(document).ready(function() {
  $('.playlist').before("<span id='currently_playing'></span>");
  $('.playlist').before("<span id='next_song'></span>");
  
  soundManager.onload = function() {
    console.log(' -- soundManager.onload has begun --');
    soundManager.debugMode = false;
    soundManager.consoleOnly = false;
    soundManager.multiShot = false;
    soundManager.playNext = true;
    
    function create_sound(song_element){
      song_url = $(song_element).attr('rel');
      next_song = $(song_element).parents('li').next().find('.playable [rel]');
      console.debug("trying to create sound for: %s", song_url);
      if (soundManager.canPlayURL( song_url) ) {
        var sound_instance = soundManager.createSound({
          id: 'song_'+($(song_element).parents('li').prevAll().length),
          url: song_url,
          volume: 95,
          playNext: true,
          consoleOnly: true,
          multiShot: false
           // whileplaying: function() {
           //   // console.log('timing' + this.position+' / '+this.duration);
           // }
        });
        console.warn('url is playable: %s', sound_instance.sID);
        
        return sound_instance;
      }
      else{
        console.warn('url not playable: %s', song_url);
        return false;
      }
    }
    
    function play_song(song_element){
      song_url = $(song_element).attr('rel');
      next_song = $(song_element).parents('li').next().find('.playable [rel]');
      
      var sound = create_sound(song_element);
      // current_song.load();
      // $(".playlist li.sm2_playing").each(function(){$(this).removeClass('sm2_playing');});
      $(".playlist li.sm2_paused").each(function(){$(this).removeClass('sm2_paused');});
      
      $('#currently_playing').html( $(song_element).html() );
      
      $(song_element).parents('li').addClass('sm2_playing');
      console.log( $(song_element).parents('li').prevAll().length);
      
      sound.play({
       onfinish:function() {
         $(song_element).parents('li').addClass('played');
         $(song_element).parents('li').removeClass('sm2_playing');
         console.debug('next song is %s', next_song.html());
         play_song(next_song);
         this.destruct(); // will also try to unload before destroying.
       },
       onpause:function(){
         console.debug( "-- paused --");
         $(song_element).parents('li').removeClass('sm2_playing');
         $(song_element).parents('li').addClass('sm2_paused');
      },
       whileplaying:function(){
         // console.log("%f", this.position/this.duration);
       }
      });
    };
        
    $(".playlist .playable").each(function(i){
      // console.log(this);
      // console.log( $(this).find('a').attr('rel') );
      console.log(this.parentNode);
      
      $(this).find('a').click(function(){
      soundManager.pauseAll();
      //pause if playing
      if ($(this).attr('class') == 'sm2_playing'){ 
        soundManager.pause('song_'+i);
        $(".playlist li.sm2_playing").each(function(){$(this).removeClass('sm2_playing');});
        $(this).addClass('sm2_paused');
        console.debug($(this).attr('class')+' :pause song_'+i);
      }
      else if ($(this).attr('class') == 'sm2_paused'){ 
        $(this).removeClass('sm2_paused');
        soundManager.resume('song_'+i);
      }
      else {
        // console.debug(i+'-----'+$(this).next().html());
        play_song(this);
       };
     });
   });
 };
  
  
  // playlist behavior
  $('.playlist_remove').click(function(){
    console.log("removing a song: %s", $(this).html());
    $.get($(this).attr('href'),'', function(){ $(this).hide('slow'); } );
  });
  
  

});

