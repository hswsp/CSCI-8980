import processing.sound.*;
SoundFile popsound;
SoundFile OVersound;
SoundFile clockSound;
SoundFile GamebgSound;
SoundFile BasicbgSound;
SoundFile PrepbgSound;
void Playsound(SoundFile file, float amplitude)
{
  // Load a soundfile from the /data folder of the sketch and play it back
  //file = new SoundFile(this, filename);
  file.amp(amplitude);
  file.play();
}

public class Audio
{
  SoundFile bgSound;
  boolean CanPlay;
  Audio(SoundFile file)
  {
    this.bgSound = file;
    CanPlay =true;
  }
  void Playsound(float amplitude)
  {
    checkplaying();
    bgSound.amp(amplitude);
    if (this.CanPlay)
    {
      bgSound.amp(amplitude);
      bgSound.play();
      CanPlay = false;
    }
  }
  void Stopsound()
  {  
    bgSound.stop();
    CanPlay = true;
  }
  void Loopsound(float amplitude)
  {
    checkplaying();
    if (this.CanPlay)
    {
      bgSound.amp(amplitude);
      bgSound.loop();
      CanPlay = false;
    }
  }
  void checkplaying()
  {
    if (!this.bgSound.isPlaying())
    {
      this.CanPlay = true;
    }
  }
}
Audio GamebgAd;
Audio BasicbgAd;
Audio PrepbgAd;
