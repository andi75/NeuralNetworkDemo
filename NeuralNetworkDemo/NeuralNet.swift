//
//  NeuralNet.swift
//  NeuralNetworkDemo
//
//  Created by Andreas Umbach on 01.08.2016.
//  Copyright © 2016 Andreas Umbach. All rights reserved.
//

import Foundation

class NeuralNet
{
    var inputLayer : Layer
    var outputLayer : Layer
    var hiddenLayers : [Layer]
    
    init()
    {
        self.inputLayer = Layer()
        self.outputLayer = Layer()
        self.hiddenLayers = [Layer]()
    }
    
    /** Creates the neural net with the specified numbers of layers and Neurons
     in each layer. The neurons in each layer have one in/out weight each */
    init(numberOfInputNeurons : Int, numberOfHiddenLayers : Int,
         numberOfNeuronsInHiddenLayer : Int, numberOfOutputNeurons : Int)
    {
        self.inputLayer = Layer(neuronCount: numberOfInputNeurons)
        self.outputLayer = Layer(neuronCount: numberOfOutputNeurons)
        self.hiddenLayers = [Layer]()
        for _ in 0..<numberOfHiddenLayers
        {
            hiddenLayers.append(Layer(neuronCount: numberOfNeuronsInHiddenLayer))
        }
    }
    
    func randomize()
    {
        inputLayer.randomize()
        outputLayer.randomize()
        for layer in hiddenLayers
        {
            layer.randomize()
        }
    }
    
    func print()
    {
        Swift.print("Input Layer:")
        inputLayer.print()
        
        Swift.print("Hidden Layers:")
        for i in 0..<hiddenLayers.count
        {
            Swift.print("Layer \(i)")
            hiddenLayers[i].print()
        }
        
        Swift.print("Ouput Layer:")
        outputLayer.print()
        
    }
}