function Get-MiddleFingerOnlySentence {
  return Get-GibberishForCharacterSet -CharacterSet $script:KeyMappings.Middle -Length 200
}