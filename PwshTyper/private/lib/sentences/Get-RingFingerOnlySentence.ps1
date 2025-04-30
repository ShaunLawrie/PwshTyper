function Get-RingFingerOnlySentence {
  return Get-GibberishForCharacterSet -CharacterSet $script:KeyMappings.Ring -Length 200
}