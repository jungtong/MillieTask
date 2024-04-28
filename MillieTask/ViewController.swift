import UIKit
import SnapKit
import Combine

final class ViewController: UIViewController {
    private let viewModel = ViewModel()

    private var bag = Set<AnyCancellable>()
    private var newsCollectionView: UICollectionView?
    private var newsDataSource: UICollectionViewDiffableDataSource<Int, NewsVO>?

    override func viewDidLoad() {
        super.viewDidLoad()

        // NewsCollectionView
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: ViewController.oneColLayout)
        collectionView.delegate = self
        collectionView.register(NewsCollectionViewCell.self, forCellWithReuseIdentifier: NewsCollectionViewCell.identifier)
        self.view.addSubview(collectionView)
        self.newsCollectionView = collectionView

        let dataSource: UICollectionViewDiffableDataSource<Int, NewsVO> = .init(collectionView: collectionView) { [weak self] collectionView, indexPath, cellInfo in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewsCollectionViewCell.identifier, for: indexPath) as? NewsCollectionViewCell ?? NewsCollectionViewCell()

            // 읽은 뉴스 여부를 cell에 반영
            let isReaded = self?.viewModel.isNewsReaded(newsHash: cellInfo.hashValue) ?? false
            cell.updateCell(info: cellInfo, isReaded: isReaded)

            cell.contentView.layer.borderWidth = 1.0
            cell.contentView.layer.borderColor = UIColor.blue.cgColor
            return cell
        }
        self.newsDataSource = dataSource

        // UpdateUI
        collectionView.snp.makeConstraints {
            $0.edges.equalTo(self.view.safeAreaLayoutGuide)
        }

        // Bind
        viewModel.newsValueSubject.receive(on: RunLoop.main).sink { [weak self] news in
            var collectionViewSnapShot = NSDiffableDataSourceSnapshot<Int, NewsVO>()
            collectionViewSnapShot.appendSections([0])
            collectionViewSnapShot.appendItems(news)
            self?.newsDataSource?.apply(collectionViewSnapShot, animatingDifferences: true)
        }.store(in: &bag)

        // FetchData
        viewModel.fetchNewsData()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        if UIDevice.current.orientation.isLandscape {
            self.newsCollectionView?.setCollectionViewLayout(ViewController.threeColLayout, animated: false) { [weak self] _ in
                // TODO: rotate시 offset 정리 필요. 일단은 최상단으로
                self?.newsCollectionView?.contentOffset = .zero
            }
        }
        else {
            self.newsCollectionView?.setCollectionViewLayout(ViewController.oneColLayout, animated: false) { [weak self] _ in
                // TODO: rotate시 offset 정리 필요. 일단은 최상단으로
                self?.newsCollectionView?.contentOffset = .zero
            }
        }
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedItem = viewModel.newsValueSubject.value[indexPath.row]

        // 읽은 뉴스 저장
        viewModel.newsRead(newsHash: selectedItem.hashValue)

        let webViewController = WebViewController(newsInfo: selectedItem)
        self.present(webViewController, animated: true) {
            (collectionView.cellForItem(at: indexPath) as? NewsCollectionViewCell)?.updateCell(info: selectedItem, isReaded: true)
        }
    }
}

extension ViewController {
    // 상황별로 다른 CollectionView Layout으로 보여주기 위해, 미리 만들어둔다.

    // 한줄 Layout
    private static let oneColLayout = UICollectionViewCompositionalLayout { sectionIndex, _ in
        let item = NSCollectionLayoutItem(
            layoutSize: .init(widthDimension: .fractionalWidth(1),
                              heightDimension: .fractionalHeight(1))
        )
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalHeight(0.2))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = NSCollectionLayoutSpacing.flexible(8)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        section.contentInsets = .init(top: 8, leading: 8, bottom: 8, trailing: 8)
        return section
    }

    // 세줄 Layout
    private static let threeColLayout = UICollectionViewCompositionalLayout { sectionIndex, _ in
        let item = NSCollectionLayoutItem(
            layoutSize: .init(widthDimension: .fractionalWidth(0.3333),
                              heightDimension: .fractionalHeight(1))
        )
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalHeight(0.2))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = NSCollectionLayoutSpacing.flexible(8)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        section.contentInsets = .init(top: 8, leading: 8, bottom: 8, trailing: 8)
        return section
    }
}
