# MoviePool

MoviePool is basic movie search app. MovieDB.org API is used for data source.

### Installation:
Just open and run the app

### Project Structure:
I prefer MVVM-R pattern on my side projects. MVVM-R is classic MVVM pattern with `State` and `Router` extensions. State is our data container which controlled by view model. Router is handling routing on view controller. For further information please check [this blog post](https://medium.com/commencis/using-redux-with-mvvm-on-ios-18212454d676).  

### Third-party Libs:
1. `Alamofire` for networking
2. `Kingfisher` for image caching
3. `Unbox` for object mapping
3. `OHHTTPStub` for stub requests
