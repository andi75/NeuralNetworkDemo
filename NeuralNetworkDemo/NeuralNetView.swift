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
        if(net == nil) { return }
        
        let r = computeRadius(net!)
        let offsets = computeHorizontalOffsets(net!.hiddenLayers.count, radius: r)
        
        // draw each layer
        var offsetPos : Int = 0
        drawNetLayer(net!.inputLayer, weightType: .Both, offset: offsets[offsetPos], radius: r)
        offsetPos += 1
        
        var lastLayer = net!.inputLayer
        for layer in net!.hiddenLayers
        {
            connectLayers(lastLayer, rightLayer: layer,
                          leftOffset: offsets[offsetPos - 1],
                          rightOffset: offsets[offsetPos],
                          radius: r)
            drawNetLayer(layer, weightType: .Both, offset: offsets[offsetPos], radius: r)
            offsetPos += 1
            lastLayer = layer
        }
        connectLayers(lastLayer, rightLayer: net!.outputLayer,
                      leftOffset: offsets[offsetPos - 1],
                      rightOffset: offsets[offsetPos],
                      radius: r)
        drawNetLayer(net!.outputLayer, weightType: .Both, offset: offsets[offsetPos], radius: r)
    }
    
    func computeRadius(net : NeuralNet) -> CGFloat
    {
        // count layers
        let layers = 2 + net.hiddenLayers.count
        // count max number of neurons in a single layer
        var maxNeurons = max(net.inputLayer.neurons.count, net.outputLayer.neurons.count)
        for layer in net.hiddenLayers
        {
            maxNeurons = max(maxNeurons, layer.neurons.count)
        }
        // compute circle size
        let horizontalDiameter = (self.bounds.width - CGFloat(layers + 1) * layerSpacing) / CGFloat(layers)
        let verticalDiameter = (self.bounds.height - CGFloat(maxNeurons + 1) * neuronSpacing) / CGFloat(maxNeurons)
        let r = min(horizontalDiameter, verticalDiameter) / 2.0
        return r
    }
    
    func computeHorizontalOffsets(hiddenLayerCount : Int, radius: CGFloat) -> [CGFloat]
    {
        var offsets = [CGFloat]()
        var offset = self.layerSpacing
        // inputLayer
        offsets.append(offset)
        // hiddenLayers
        for _ in 0..<hiddenLayerCount
        {
            offset += 2 * radius + layerSpacing
            offsets.append(offset)
        }
        // outputLayer
        offset += 2 * radius + layerSpacing
        offsets.append(offset)
        return offsets
    }
    
    enum WeightType { case InputWeight, OutputWeight, Both, None }
    
    func drawSingleWeights(weights : [Double], rect: CGRect)
    {
        var weightString = ""
        for i in 0..<weights.count
        {
            weightString = String.localizedStringWithFormat("%@%.2f", weightString, weights[i])
            // insert \n delimiter between weights, but don't add one after the last weight, or the text won't align propertly vertically
            if(i != weights.count - 1)
            {
                weightString = String.localizedStringWithFormat("%@\n", weightString)
            }
        }
        
        // weightString.drawWithRect( CGRectInset(rect, radius / 2, radius / 2), options: .UsesLineFragmentOrigin, attributes: nil, context: nil )
        NeuralNetView.drawString(weightString, font: UIFont.systemFontOfSize(UIFont.systemFontSize()), rect: rect)
    }
    
    func computeVerticalOffsets(layer : Layer, weightType: WeightType, radius: CGFloat) -> [CGFloat]
    {
        var vOffsets = [CGFloat]()
        
        var vOffset = (self.bounds.height - 2 * radius * CGFloat(layer.neurons.count) - CGFloat(layer.neurons.count - 1) * self.neuronSpacing) / 2
        for neuron in layer.neurons
        {
            switch(weightType)
            {
            case .InputWeight:
                for _ in neuron.weightsIn
                {
                    vOffsets.append(vOffset)
                }
            case .OutputWeight:
                for _ in neuron.weightsOut
                {
                    vOffsets.append(vOffset)
                }
            case .None:
                vOffsets.append(vOffset)
                
            case .Both:
                assert(false)
            }
            vOffset += (2 * radius + self.neuronSpacing)
        }
        return vOffsets
    }
    
    func connectLayers(leftLayer : Layer, rightLayer : Layer,
                       leftOffset: CGFloat, rightOffset: CGFloat,
                       radius: CGFloat)
    {
        let ctx = UIGraphicsGetCurrentContext()

        let vOffsetsLeft = computeVerticalOffsets(leftLayer, weightType: .OutputWeight, radius: radius)
        let vOffsetsRight = computeVerticalOffsets(rightLayer, weightType: .InputWeight, radius: radius)
        
        assert(vOffsetsLeft.count == vOffsetsRight.count)
        
        for i in 0..<vOffsetsLeft.count
        {
            let y1 = vOffsetsLeft[i]
            let y2 = vOffsetsRight[i]
            let r1 = CGRectMake(leftOffset, y1, 2 * radius, 2 * radius)
            let r2 = CGRectMake(rightOffset, y2, 2 * radius, 2 * radius)

            let points = [
                CGPointMake(CGRectGetMidX(r1), CGRectGetMidY(r1)),
                CGPointMake(CGRectGetMidX(r2), CGRectGetMidY(r2))
            ]
            let dx = points[1].x - points[0].x
            let dy = points[1].y - points[0].y
            
            let l = sqrt(dx * dx + dy * dy)
            let circlePoints = [
                    CGPointMake(points[0].x + dx * radius / l, points[0].y + dy * radius / l),
                    CGPointMake(points[1].x - dx * radius / l, points[1].y - dy * radius / l),
            ]
            CGContextStrokeLineSegments(ctx, circlePoints, 2)
        }
    }

    func drawNetLayer(layer : Layer, weightType : WeightType, offset: CGFloat, radius: CGFloat)
    {
        let ctx = UIGraphicsGetCurrentContext()
        // draw circles for each neuron
        let vOffsets = computeVerticalOffsets(layer, weightType: .None, radius: radius)
        
        for i in 0..<layer.neurons.count
        {
            let neuron = layer.neurons[i]
            let vOffset = vOffsets[i]
            
            let rect = CGRectMake(offset, vOffset, 2 * radius, 2 * radius)
            CGContextStrokeEllipseInRect(ctx, rect)
            
            switch(weightType)
            {
            case .InputWeight:
                drawSingleWeights(neuron.weightsIn, rect: CGRectInset(rect, radius / 2, radius / 2))
            case .OutputWeight:
                drawSingleWeights(neuron.weightsOut, rect: CGRectInset(rect, radius / 2, radius / 2))
            case .Both:
                let r1 = CGRectMake(
                    rect.origin.x + rect.width * 1 / 8,
                    rect.origin.y + rect.height / 3,
                    radius / 3, rect.height / 3
                )
                let r2 = CGRectMake(
                    rect.origin.x + rect.width * 5 / 8,
                    rect.origin.y + rect.height / 3,
                    radius / 3, rect.height / 3
                )
                drawSingleWeights(neuron.weightsIn, rect: r1)
                drawSingleWeights(neuron.weightsOut, rect: r2)
                break
            case .None:
                assert(false)
                break
            }
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
