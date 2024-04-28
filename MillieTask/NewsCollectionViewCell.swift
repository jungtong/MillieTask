import UIKit

class NewsCollectionViewCell: UICollectionViewCell {
    static let identifier = "NewsCollectionViewCell"

    let titleLabel: UILabel
    let imageView: UIImageView
    let publishedAtLabel: UILabel

    override init(frame: CGRect) {
        self.titleLabel = UILabel()
        self.imageView = UIImageView()
        self.publishedAtLabel = UILabel()

        super.init(frame: frame)

        titleLabel.textAlignment = .center
        titleLabel.font = .systemFont(ofSize: 16)

        publishedAtLabel.textAlignment = .right
        publishedAtLabel.font = .systemFont(ofSize: 10)
        publishedAtLabel.textColor = .black

        self.contentView.addSubview(imageView)
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(publishedAtLabel)

        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        titleLabel.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview().inset(4)
        }
        publishedAtLabel.snp.makeConstraints {
            $0.bottom.horizontalEdges.equalToSuperview().inset(4)
        }
    }

    func updateCell(info: NewsVO, isReaded: Bool) {
        self.titleLabel.text = info.title
        self.titleLabel.textColor = isReaded ? .red : .black
        self.publishedAtLabel.text = info.publishedAt

        self.imageView.image = nil
        Task { [weak self] in
            self?.imageView.image = try await Api.getUIImageWithCoreData(urlString: info.urlToImage)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
