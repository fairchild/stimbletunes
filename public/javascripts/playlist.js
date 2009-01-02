$(document).ready(function() {
  
  $('.playlist').sortable({
    axis:'y',
    opacity:0.75,
    update:function(event, ui){
      console.log('stopped sorting %o, %o', ui.item, ui.position);
      playlist_song_id = ui.item.attr('id').match(/\d+$/);
      previous_song_id = ui.item.prev().attr('id').match(/\d+$/);
      next_song_id     = ui.item.next('li').attr('id').match(/\d+$/);
      position =  ui.item.prevAll().length;
      console.info("playlist song id= %o", ui.item.next('li').attr('id'));
      $.ajax({
        type: "PUT",
        url: '/playlist/reorder/',
        data: {'position':position, 'previous':previous_song_id, 'middle':playlist_song_id, 'next':next_song_id} 
        });
      }
    });
  
  $('.playlist_remove').click(function(){
    this_link = $(this);
    url = this_link.attr('href');
    $(this).attr('href', '#');
    console.log("removing a song: %s", $(this).html());
    $.get(url, '', function(data, text_status){ 
      this_link.parents('li').hide(); 
      console.info("Removed song from playlist: %o", this);
      } 
    );
  });
  
  $('.enque_button').click(function(data){
      this_enque_button = $(this);
      $.get( $(this).attr('rel'), '', function(){ $(this_enque_button).html('^'); } );
      $(this).addClass('enqued');
    });
  
});
