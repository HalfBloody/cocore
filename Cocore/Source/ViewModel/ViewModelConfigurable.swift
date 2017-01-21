//
//  ViewModelConfigurable.swift
//  PrizeArena
//
//  Created by Dmitry Shashlov on 23/01/16.
//  Copyright © 2017 Dmitry Shashlov. All rights reserved.
//

import Foundation

public protocol ViewModelConfigurable {
    associatedtype ModelType
    func configureWithViewModel(viewModel: ViewModel<ModelType>)
}