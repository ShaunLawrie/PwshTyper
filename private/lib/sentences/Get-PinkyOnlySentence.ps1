function Get-PinkyOnlySentence {
  return Get-GibberishForCharacterSet -CharacterSet $script:KeyMappings.Pinky -Length 200
}