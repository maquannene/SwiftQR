use_frameworks!

target 'SwiftQR' do

pod 'SnapKit'
pod 'Then', '2.1.0'
pod 'libqrencode', :git => 'https://github.com/maquannene/libqrencode-forXcode.git'
pod "EFQRCode", '1.2.7'

end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end
