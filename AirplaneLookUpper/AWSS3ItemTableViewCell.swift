//
// AWSS3ItemTableViewCell.swift
// AWSS3Integration
//
// Created by Soham Paul
// Copyright © 2019 Personal. All rights reserved.
//
import UIKit
class AWSS3ItemTableViewCell: UITableViewCell {
    @IBOutlet weak var cellIconView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    override func awakeFromNib() {
        super.awakeFromNib()
        cellIconView.layer.masksToBounds = true
        cellIconView.clipsToBounds = true
        cellIconView.layer.cornerRadius = 5.0
    }
    func configure(_ task: DataDownloader) {
        switch task.state {
        case .pending:
            progressBar.isHidden = true
            subtitleLabel.isHidden = true
            cellIconView.isHidden = true
        case .inProgess(let complete):
            progressBar.isHidden = false
            progressBar.progress = Float(Double(complete))
            subtitleLabel.isHidden = false
            // print(“cell progress :: “,complete)
            subtitleLabel.text = "\(complete * 100)%"
            cellIconView.isHidden = false
            UIView.animate(withDuration:TimeInterval(complete)) {
                self.progressBar.setProgress(1.0, animated: true)
            }
        case .completed:
            progressBar.isHidden = true
            subtitleLabel.isHidden = true
            cellIconView.isHidden = false
        }
    }
}
