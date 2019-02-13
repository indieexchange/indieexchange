$ ->
  new ProfilePictureCrop()

class ProfilePictureCrop
  constructor: ->
    width = parseInt($('#cropbox').width())
    height = parseInt($('#cropbox').height())
    $('#cropbox').Jcrop
      aspectRatio: 1
      setSelect: [0, 0, width, height]
      onSelect: @update
      onChange: @update

  update: (coords) =>
    $('#user_crop_x').val(coords.x)
    $('#user_crop_y').val(coords.y)
    $('#user_crop_w').val(coords.w)
    $('#user_crop_h').val(coords.h)
    @updatePreview(coords)

  updatePreview: (coords) =>
    rx = 100 / coords.w
    ry = 100 / coords.h

    $('#preview').css
        width: Math.round(rx * $('#cropbox').width()) + 'px'
        height: Math.round(ry * $('#cropbox').height()) + 'px'
        marginLeft: '-' + Math.round(rx * coords.x) + 'px'
        marginTop: '-' + Math.round(ry * coords.y) + 'px'