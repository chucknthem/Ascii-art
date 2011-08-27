ASCII_GRADIENT= ['#', 'G', '+', '-', '.', '&nbsp;']
# Id selector alias.
$ = (id) -> document.getElementById(id)

# Convert a grayscale image into an ascii image.
img2Ascii = (img, lineSep='<br />') ->
  # Assumes a grayscale image.
  ascii = []
  gradLen = ASCII_GRADIENT.length
  for j in [0..img.height - 1]
    for i in [0..img.width - 1]
      index = 4 * j * img.width + i * 4
      colorIndex = Math.floor(img.data[index + 1] / 255.0 * gradLen)
      ascii.push(ASCII_GRADIENT[colorIndex])
    ascii.push(lineSep)
  return ascii.join('')


# Convert rgbImg to a grayscale image and store it in grayImg
rgb2Grayscale = (rgbImg, grayImg) ->
  rgbData = rgbImg.data
  grayData = grayImg.data
  for j in [0..rgbImg.height - 1]
    for i in [0..rgbImg.width - 1]
      index = 4 * j * rgbImg.width + i * 4
      grayPixel = (rgbData[index + 0] + rgbData[index + 1] + rgbData[index + 2]) / 3

      grayData[index + k] = grayPixel for k in [0..2]
      grayData[index + 3] = rgbData[index + 3]

  return grayData


# Resize srcImg to the size of destImg.
resize = (srcImg, destImg) ->
  ratio = srcImg.width * srcImg.height * 1.0 / (destImg.width * destImg.height)
  ratioW = srcImg.width * 1.0 / destImg.width
  ratioH = srcImg.height * 1.0 / destImg.height
  for j in [0..destImg.height - 1]
    for i in [0..destImg.width - 1]
      dIndex = 4 * j * destImg.width + i * 4
      x = Math.floor(ratioW * i)
      y = Math.floor(ratioH * j)
      sIndex = 4 * y * srcImg.width + x * 4
      destImg.data[dIndex + k] = srcImg.data[sIndex + k] for k in [0..3]


fitScale = (width, height, maxDim) ->
  ratio = if width > height then maxDim * 1.0 / width else maxDim * 1.0 / height
  return [width * ratio, height * ratio]


loadImg = (e) ->
  can = $ 'canvas'
  ctx = can.getContext '2d'

  thumbSize = 128
  can.width = this.width * 2
  can.height = this.height + thumbSize
  ctx.drawImage(this, 0, 0)

  rgbImg = ctx.getImageData(0, 0, this.width, this.height)
  grayImg = ctx.createImageData(this.width, this.height)

  thumbDim = fitScale(this.width, this.height, thumbSize)
  thumbImg = ctx.createImageData(thumbDim[0], thumbDim[1])
  thumbGrayImg = ctx.createImageData(thumbDim[0], thumbDim[1])
  resize(rgbImg, thumbImg)

  rgb2Grayscale(rgbImg, grayImg)
  rgb2Grayscale(thumbImg, thumbGrayImg)
  #ctx.putImageData(grayImg, this.width, 0)
  #ctx.putImageData(thumbImg, 0, this.height)
  #ctx.putImageData(thumbGrayImg, thumbGrayImg.width, this.height)

  $('ascii').innerHTML = img2Ascii(thumbGrayImg)


uploadImage = (file) ->
  window.URL = window.URL || window.webkitURL
  if not file.type.match /image.*/
    alert 'invalid file type'
    return
  img = new Image
  img.onload = (e) ->
    loadImg.call(this, e)
    window.URL.revokeObjectURL(this.src)
  img.src = window.URL.createObjectURL(file)


# Main.
$('file').addEventListener('change', (e) ->
  uploadImage(this.files[0])
)

