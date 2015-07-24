
Pod::Spec.new do |s|

  s.name         = "SFPullRefresh"
  s.version      = "1.0.1"
  s.summary      = "simple pull refresh for UITableView and UICollectionView"

  s.description  = <<-DESC
                    simple pull refresh for UITableView and UICollectionView, you can set the position of refresh and loadmore control, support custom refresh and loadmore control
                   DESC

  s.homepage     = "https://github.com/sofach/SFPullRefresh"

  s.license      = "MIT"

  s.author       = { "sofach" => "mamihlapinatapai@126.com" }

  s.platform     = :ios
  s.platform     = :ios, "5.0"

  s.source       = { :git => "https://github.com/sofach/SFPullRefresh.git", :tag => "1.0.1" }


  s.source_files  = "SFPullRefresh/lib/**/*.{h,m}"
  s.requires_arc = true

end
