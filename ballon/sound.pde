import processing.sound.*;
SoundFile popsound;
SoundFile OVersound;



void Playsound(SoundFile file,String filename)
{
  // Load a soundfile from the /data folder of the sketch and play it back
  file = new SoundFile(this, filename);
  file.play();
}
