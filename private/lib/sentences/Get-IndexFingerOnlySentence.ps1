function Get-IndexFingerOnlySentence {
  return Get-GibberishForCharacterSet -CharacterSet $script:KeyMappings.Index -Length 200
}