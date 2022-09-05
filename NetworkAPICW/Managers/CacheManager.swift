//
//  CacheManager.swift
//  NetworkAPICW
//
//  Created by Martynov Evgeny on 5.09.22.
//

import AlamofireImage

// не поддается наследованию и все его методы косвенным образом приобретают свойство final
final class CacheManager {
    // MARK: Lifecycle

    private init() {}

    // MARK: Internal

    static let shared = CacheManager()

    let imageCache = AutoPurgingImageCache(
        memoryCapacity: 100_000_000,
        preferredMemoryUsageAfterPurge: 60_000_000
    )
}
