//
//  NeuralNetView.swift
//  NeuralNetworkDemo
//
//  Created by Andreas Umbach on 02.08.2016.
//  Copyright © 2016 Andreas Umbach. All rights reserved.
//

import Foundation
import UIKit

class NeuralNetView : UIView
{
    var viewController : ViewController?
    
    let layerSpacing : CGFloat = 60
    let neuronSpacing : CGFloat = 30
    
    override func drawRect(rect: CGRect) {
        let net = self.viewController?.net
        if(net == nil)
        {
            return
        }
        else
        {
            // count layers
            let layers = 2 + net!.hiddenLayers.count
            // count max number of neurons in a single layer
            var maxNeurons = max(net!.inputLayer.neurons.count, net!.outputLayer.neurons.count)
            for layer in net!.hiddenLayers
            {
                maxNeurons = max(maxNeurons, layer.neurons.count)
            }
            // compute circle size
            let horizontalDiameter = (self.bounds.width - CGFloat(layers + 1) * layerSpacing) / CGFloat(layers)
            let verticalDiameter = (self.bounds.height - CGFloat(maxNeurons + 1) * neuronSpacing) / CGFloat(maxNeurons)
            let r = min(horizontalDiameter, verticalDiameter) / 2.0
            // draw each layer
            var offset = layerSpacing
            drawNetLayer(net!.inputLayer, weightType: .InputWeight, offset: offset, radius: r)
            for layer in net!.hiddenLayers
            {
                offset += 2 * r + layerSpacing
                drawNetLayer(layer, weightType: .InputWeight, offset: offset, radius: r)
            }
            offset += 2 * r + layerSpacing
            drawNetLayer(net!.outputLayer, weightType: .OutputWeight, offset: offset, radius: r)
        }
    }
    
    enum WeightType { case InputWeight, OutputWeight }
    
    func drawNetLayer(layer : Layer, weightType : WeightType, offset: CGFloat, radius: CGFloat)
    {
        let ctx = UIGraphicsGetCurrentContext()
        // draw circles for each neuron
        var vOffset = (self.bounds.height - 2 * radius * CGFloat(layer.neurons.count) - CGFloat(layer.neurons.count - 1) * neuronSpacing) / 2
        for neuron in layer.neurons
        {
            let rect = CGRectMake(offset, vOffset, 2 * radius, 2 * radius)
            CGContextStrokeEllipseInRect(ctx, rect)
            
            let weight : Double
            switch(weightType)
            {
            case .InputWeight: weight = neuron.weightsIn[0]
            case .OutputWeight: weight = neuron.weightsOut[0]
            }
            let weightString : String = String.localizedStringWithFormat("%.2f", weight)
            
            // weightString.drawWithRect( CGRectInset(rect, radius / 2, radius / 2), options: .UsesLineFragmentOrigin, attributes: nil, context: nil )
            NeuralNetView.drawString(weightString, font: UIFont.systemFontOfSize(UIFont.systemFontSize()), rect: CGRectInset(rect, radius / 2, radius / 2))
            vOffset += (2 * radius + neuronSpacing)
        }
    }
    
    /* adjusted from an objective-C function from StackOverflow: http://stackoverflow.com/questions/1302824/ */
    class func drawString(s : String, font: UIFont, rect: CGRect)
    {
        let paragraphStyle : NSMutableParagraphStyle = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        paragraphStyle.alignment = NSTextAlignment.Center
        
        let attributes = [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: UIColor.blackColor(),
            NSParagraphStyleAttributeName: paragraphStyle
        ]
        let size = (s as NSString).sizeWithAttributes(attributes)
        let textRect = CGRectMake(rect.origin.x + floor((rect.size.width - size.width) / 2),
                                  rect.origin.y + floor((rect.size.height - size.height) / 2),
                                  size.width,
                                  size.height)
        s.drawWithRect(textRect, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: attributes, context: nil)
    }
 }
