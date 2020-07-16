//
//  GameSettingsViewController.swift
//  GameCountHelper
//
//  Created by Vlad on 5/22/20.
//  Copyright © 2020 Alexx. All rights reserved.
//

import UIKit
import BoxView


class GameSettingsViewController: TopBarViewController, UITableViewDelegate, UITableViewDataSource {
    
    var players = [Player]()
    
    let tableView = ContentSizedTableView.newAutoLayout()
    var tableHeight: NSLayoutConstraint?
    
    let gameButton = SkinButton()

    var hasSession: Bool {
        return GameManager.shared.currentSession != nil
    }
    
    var playerCellGroups = [SkinKey: SkinGroup]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupForGameState()
    }
    
    override func setupViewContent() {
        super.setupViewContent()
        tableView.estimatedRowHeight = 100.0;
        tableView.rowHeight = UITableView.automaticDimension;
        
        contentBoxView.items = [
            tableView.boxed,
            gameButton.boxed.all(16.0).bottom(>=16.0)
        ]
        gameButton.layer.cornerRadius = 10.0
        setupForGameState()
        
        setupTableView()
        
        setupMenuItems()
        tableView.onSizeUpdate = { [unowned self] sz in
            print("sz.height: \(sz.height)")
            let height = (sz.height >= 10.0) ? sz.height : 10.0
            if let tableHeight = self.tableHeight {
                tableHeight.constant = height
                if height > 10.0 {
                    UIView.animate(withDuration: 0.3) {
                        self.view.layoutIfNeeded()
                    }
                }
            }
            else {
                self.tableHeight = self.tableView.bxPinHeight(<=height)
            }
        }
    }
    
    override func updateSkin(_ skin: Skin) {
        super.updateSkin(skin)
        playerCellGroups = [.button: skin.barButton,
                            .label: skin.h2.normalGroup,
                            .image: skin.avatar.normalGroup]
        gameButton.setSkinGroups([.button: skin.keyStyles])
    }
    
    func startGame(with session: GameSession) {
        navigationController?.popToRootViewController(animated: true)
        let sessionVC = GameSessionViewController(game: session)
        self.navigationController?.pushViewController(sessionVC, animated: true)
    }
    
    func setupForGameState() {
        if let session = GameManager.shared.currentSession {
            gameButton.setTitle("Resume Game".ls)
            gameButton.onClick = { [unowned self] btn in
                self.startGame(with: session)
            }
        } else {
            gameButton.setTitle("Start Game".ls)
            gameButton.onClick = { [unowned self] btn in
                self.startGame(with: GameManager.shared.newSession(with: self.players))
            }
        }
        tableView.reloadData()
    }
    
    func setupTableView() {
        tableView.isEditing = true
        tableView.allowsSelectionDuringEditing = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        PlayerTableViewCell.register(tableView: tableView)
        AddPlayerTableViewCell.register(tableView: tableView)
        tableView.bxPinHeight(>=10.0)
        tableView.setContentCompressionResistancePriority(.required, for: .vertical)
        tableView.backgroundColor = .clear
    }
        
    func setupMenuItems() {
        topBarView.titleLabel.text = "Players"
    }
    
    func updateWithPlayer(_ player: Player?) {
        if let player = player {
            self.players.append(player)
            self.tableView.reloadData()
        }
    }
    
    func addPlayer() {
        let allPlayers = Player.fetchAllInstances(in: viewContext)
        let otherPlayers = allPlayers.filter{!players.contains($0)}
        if otherPlayers.count == 0 {
            let newPlayerVC = EditPlayerViewController() { [weak self]  player in
                guard let self = self else { return }
                self.updateWithPlayer(player)
            }
            navigationController?.pushViewController(newPlayerVC, animated: true)
        }
        else {
            let listVC = PlayerListViewController()
            listVC.players = otherPlayers
            listVC.handler = { player in
                self.updateWithPlayer(player)
            }
            navigationController?.pushViewController(listVC, animated: true)
        }
    }
    
    func removePlayer(number: Int) {
        let player = players[number]
        players.remove(at: number)
        tableView.reloadData()
    }
    
// MARK: - UITableViewDelegate methods
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }

    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 0
    }
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if proposedDestinationIndexPath.section == 0 {
            return proposedDestinationIndexPath
        } else {
            let indexPath = IndexPath(row: players.count - 1, section: 0)
            return indexPath
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let player = players[sourceIndexPath.row]
        players.remove(at: sourceIndexPath.row)
        players.insert(player, at: destinationIndexPath.row)
        GameManager.shared.currentSession?.players = players
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let playerVC = EditPlayerViewController(player: players[indexPath.row]) { [weak self]  player in
                guard let self = self else { return }
                self.players[indexPath.row] = player
                tableView.reloadData()
            }
            navigationController?.pushViewController(playerVC, animated: true)
        } else {
            addPlayer()
        }
        
    }
    
// MARK: - UITableViewDataSource methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if hasSession {
            return 1
        } else {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return players.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = PlayerTableViewCell.dequeue(tableView: tableView)
            let player = players[indexPath.row]
            cell.avatar = player.image
            cell.label.text = player.name
            if hasSession {
                cell.showRemoveButton = false
            } else {
                cell.showRemoveButton = true
                cell.removeButton.setImage(.template("minus"))
                
                cell.removeButton.onClick = {btn in
                    self.removePlayer(number: indexPath.row)
                }
                if let skin = skin {
                    cell.setSkinGroups(playerCellGroups)
                }
                
            }
            return cell
        } else {
            let cell = AddPlayerTableViewCell.dequeue(tableView: tableView)
            cell.plusImageView.image = .template("plus")
            cell.label.text = "Add Player"
            if let brush = skin?.barButton.styleForState(.normal)?.textDrawing?.brush {
                cell.plusImageView.setImageBrush(brush)
            }
            cell.label.setSkinStyle(skin?.h2)
            return cell
        }
        
    }
}
