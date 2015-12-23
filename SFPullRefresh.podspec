
Pod::Spec.new do |s|

  s.name         = "SFPullRefresh"
  s.version      = "1.1.4"
  s.summary      = "add simple pull refresh to UITableView or UICollectionView"

  s.description  = <<-DESC
                    easy pull refresh for UITableView and UICollectionView, support custom refresh and loadmore control
                   DESC

  s.homepage     = "https://github.com/sofach/SFPullRefresh"

  s.license      = "MIT"

  s.author       = { "sofach" => "sofach@126.com" }

  s.platform     = :ios
  s.platform     = :ios, "5.0"

  s.source       = { :git => "https://github.com/sofach/SFPullRefresh.git", :tag => "1.1.4" }


  s.source_files  = "SFPullRefresh/lib/**/*.{h,m}"
  s.requires_arc = true

end
