//
//  MovieTableViewCell.swift
//  MoviePool
//
//  Created by EGEMEN AYHAN on 28.05.2018.
//  Copyright © 2018 EGEMEN AYHAN. All rights reserved.
//

import Networker
import Kingfisher

class MovieTableViewCell: UITableViewCell {

    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var releaseDateStackView: UIStackView!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    
    static let reuseIdentifier = "movieCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        posterImageView.layer.cornerRadius = 5.0
        posterImageView.layer.masksToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        posterImageView.image = nil
        
        releaseDateLabel.text = nil
        releaseDateStackView.isHidden = true
        
        overviewLabel.text = nil
        overviewLabel.isHidden = true
    }
    
    func configure(with movie:Movie) {
        titleLabel.text = movie.title
        
        if let releaseDate = movie.formattedReleaseDate() {
            releaseDateLabel.text = releaseDate
            releaseDateStackView.isHidden = false
        }
        
        if let overview = movie.overview {
            overviewLabel.text = overview
            overviewLabel.isHidden = false
        }
        
        let posterResource = movie.imageURL(forSize: .w185)
        posterImageView.kf.setImage(with: posterResource,
                                    placeholder: Image(named: "placeholder"))
    }

}
