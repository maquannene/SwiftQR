use_frameworks!

target 'SwiftQR' do

pod 'SnapKit', '3.2.0'
pod 'Then', '2.1.0'
pod "EFQRCode", '1.2.7'

end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end
