Pod::Spec.new do |spec|
  spec.platform = :ios
  spec.ios.deployment_target = '10.0'
  spec.name         = 'DomainLayer'
  spec.version      = '0.1'
  spec.license      = { :type => '' }
  spec.homepage     = 'https://github.com/wavesplatform/WavesWallet-iOS/'
  spec.authors      = { '' => '' }
  spec.summary      = 'DomainLayer'
  spec.source       = { :path => 'Sources/**/*.{swift}' }
  spec.source_files = 'Sources/**/*.{swift}'

  spec.static_framework = true
  spec.dependency 'Firebase/Core'
  spec.dependency 'Firebase/Database'
  spec.dependency 'Firebase/Auth'
  spec.dependency 'RxReachability'
  spec.dependency '25519'
  spec.dependency 'Base58'
  spec.dependency 'Keccak'
  spec.dependency 'Blake2'

  spec.dependency 'CryptoSwift'
  spec.dependency 'KeychainAccess'
  spec.dependency 'DeviceKit', '~> 1.3'
  spec.dependency 'RealmSwift'
  spec.dependency 'RxRealm'
  spec.dependency 'Moya/RxSwift'
  spec.dependency 'CSV.swift'



end
